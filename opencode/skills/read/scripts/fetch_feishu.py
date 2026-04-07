#!/usr/bin/env python3
"""Fetch Feishu/Lark document as Markdown via Feishu Open API.

Special thanks to joeseesun for the excellent qiaomu-markdown-proxy project,
which inspired the Feishu API integration and document parsing approach here.
https://github.com/joeseesun/qiaomu-markdown-proxy

Requirements:
    pip install requests

Setup:
    export FEISHU_APP_ID=your_app_id
    export FEISHU_APP_SECRET=your_app_secret
    App needs: docx:document:readonly, wiki:wiki:readonly

Usage:
    python3 fetch_feishu.py <feishu_url>
    python3 fetch_feishu.py <feishu_url> --json
"""

import json
import os
import re
import sys
import urllib.parse

try:
    import requests
except ImportError:
    print("Error: requests not installed. Run: pip install requests", file=sys.stderr)
    sys.exit(1)

API = "https://open.feishu.cn/open-apis"


def get_token():
    app_id = os.environ.get("FEISHU_APP_ID")
    app_secret = os.environ.get("FEISHU_APP_SECRET")
    if not app_id or not app_secret:
        return None, "FEISHU_APP_ID or FEISHU_APP_SECRET not set"
    resp = requests.post(
        f"{API}/auth/v3/tenant_access_token/internal",
        json={"app_id": app_id, "app_secret": app_secret},
    )
    d = resp.json()
    if d.get("code") != 0:
        return None, f"Auth failed: {d.get('msg', resp.text)}"
    return d["tenant_access_token"], None


def parse_url(url):
    patterns = [
        (r"feishu\.cn/docx/([A-Za-z0-9]+)", "docx"),
        (r"feishu\.cn/wiki/([A-Za-z0-9]+)", "wiki"),
        (r"larksuite\.com/docx/([A-Za-z0-9]+)", "docx"),
        (r"larksuite\.com/wiki/([A-Za-z0-9]+)", "wiki"),
    ]
    for pattern, doc_type in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1), doc_type
    if re.search(r"(feishu\.cn|larksuite\.com)/docs/", url):
        return None, "legacy_doc"
    return url, "docx"


def resolve_wiki(token, wiki_token):
    resp = requests.get(
        f"{API}/wiki/v2/spaces/get_node",
        headers={"Authorization": f"Bearer {token}"},
        params={"token": wiki_token},
    )
    d = resp.json()
    if d.get("code") == 0:
        node = d["data"]["node"]
        return node.get("obj_token"), node.get("obj_type")
    return None, None


def get_blocks(token, doc_id):
    blocks, page_token = [], None
    while True:
        params = {"page_size": 500}
        if page_token:
            params["page_token"] = page_token
        resp = requests.get(
            f"{API}/docx/v1/documents/{doc_id}/blocks",
            headers={"Authorization": f"Bearer {token}"},
            params=params,
        )
        d = resp.json()
        if d.get("code") != 0:
            return None, f"Blocks fetch failed: {d.get('msg', resp.text)}"
        blocks.extend(d["data"].get("items", []))
        if not d["data"].get("has_more"):
            break
        page_token = d["data"].get("page_token")
    return blocks, None


def extract_text(elements):
    if not elements:
        return ""
    parts = []
    for element in elements:
        if "text_run" in element:
            text_run = element["text_run"]
            text = text_run.get("content", "")
            style = text_run.get("text_element_style", {})
            if style.get("bold"):
                text = f"**{text}**"
            if style.get("italic"):
                text = f"*{text}*"
            if style.get("inline_code"):
                text = f"`{text}`"
            if style.get("link", {}).get("url"):
                text = f"[{text}]({urllib.parse.unquote(style['link']['url'])})"
            parts.append(text)
        elif "mention_user" in element:
            parts.append(f"@{element['mention_user'].get('user_id', 'user')}")
        elif "equation" in element:
            parts.append(f"${element['equation'].get('content', '')}$")
    return "".join(parts)


LANG_MAP = {
    7: "bash",
    8: "c",
    9: "csharp",
    10: "cpp",
    14: "css",
    19: "dockerfile",
    25: "go",
    29: "html",
    31: "java",
    32: "javascript",
    33: "json",
    35: "kotlin",
    40: "markdown",
    46: "php",
    50: "python",
    52: "ruby",
    53: "rust",
    58: "sql",
    59: "swift",
    62: "typescript",
    68: "xml",
    69: "yaml",
}


def blocks_to_md(blocks):
    lines = []
    counters = {}
    for block in blocks:
        block_type = block.get("block_type")
        parent_id = block.get("parent_id", "")

        if block_type == 2:
            text = extract_text(block.get("text", {}).get("elements", []))
            lines.append(text if text.strip() else "")
        elif block_type in range(3, 10):
            level = block_type - 2
            key = f"heading{level}"
            data = block.get(key) or block.get("heading", {})
            text = extract_text(data.get("elements", []))
            lines.append(f"{'#' * level} {text}")
        elif block_type == 10:
            text = extract_text(block.get("bullet", {}).get("elements", []))
            lines.append(f"- {text}")
        elif block_type == 11:
            text = extract_text(block.get("ordered", {}).get("elements", []))
            number = counters.get(parent_id, 0) + 1
            counters[parent_id] = number
            lines.append(f"{number}. {text}")
        elif block_type == 12:
            code_data = block.get("code", {})
            text = extract_text(code_data.get("elements", []))
            lang = LANG_MAP.get(code_data.get("style", {}).get("language", 0), "")
            lines.extend([f"```{lang}", text, "```"])
        elif block_type == 13:
            text = extract_text(block.get("quote", {}).get("elements", []))
            lines.append(f"> {text}")
        elif block_type == 15:
            todo_data = block.get("todo", {})
            text = extract_text(todo_data.get("elements", []))
            done = todo_data.get("style", {}).get("done", False)
            lines.append(f"- {'[x]' if done else '[ ]'} {text}")
        elif block_type == 16:
            lines.append("---")
        elif block_type == 17:
            token = block.get("image", {}).get("token", "")
            lines.append(f"![image](feishu-image://{token})")
        elif block_type == 1:
            continue
        else:
            for value in block.values():
                if isinstance(value, dict) and "elements" in value:
                    text = extract_text(value["elements"])
                    if text.strip():
                        lines.append(text)
                    break

    return "\n\n".join(lines)


def fetch_feishu(url):
    doc_id, doc_type = parse_url(url)

    if doc_type == "legacy_doc":
        return {"error": "Unsupported Feishu URL: legacy docs URLs are not supported, use a docx or wiki URL"}

    token, err = get_token()
    if err:
        return {"error": err}

    if doc_type == "wiki":
        real_id, real_type = resolve_wiki(token, doc_id)
        if not real_id:
            return {"error": f"Cannot resolve wiki node: {doc_id}"}
        if real_type and real_type != "docx":
            return {"error": f"Unsupported wiki target type: {real_type}"}
        doc_id, doc_type = real_id, "docx"

    info_resp = requests.get(
        f"{API}/docx/v1/documents/{doc_id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    doc_info = info_resp.json().get("data", {}).get("document", {})
    title = doc_info.get("title", "")

    blocks, err = get_blocks(token, doc_id)
    if err:
        return {"error": err}

    return {
        "title": title,
        "document_id": doc_id,
        "url": url,
        "content": blocks_to_md(blocks),
    }


def to_markdown(result):
    if "error" in result:
        return f"Error: {result['error']}"
    parts = [
        "---",
        f'title: "{result["title"]}"',
        f'document_id: "{result["document_id"]}"',
        f'url: "{result["url"]}"',
        "---",
        "",
        f"# {result['title']}" if result.get("title") else "",
        "",
        result.get("content", ""),
    ]
    return "\n".join(parts)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: fetch_feishu.py <feishu_url> [--json]", file=sys.stderr)
        print("  Requires: FEISHU_APP_ID, FEISHU_APP_SECRET", file=sys.stderr)
        sys.exit(1)

    result = fetch_feishu(sys.argv[1])
    if "--json" in sys.argv:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(to_markdown(result))
