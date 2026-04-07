---
name: read
description: Use when given any URL, web page link, or PDF to read. Fetches clean Markdown through the route-specific method, saves to Downloads by default, then stops.
version: 3.0.0
allowed-tools:
  - bash
  - read
  - webfetch
---

# Read: Fetch Any URL or PDF as Markdown

Convert a URL or PDF into clean Markdown, save it, report the saved path, then stop.

Do not use this skill for repo files that are already local and readable with tools like `read`.

## Routing

| Input | Method |
|-------|--------|
| `feishu.cn`, `larksuite.com` | Run `python3 opencode/skills/read/scripts/fetch_feishu.py "{url}"` |
| WeChat public account article | First use proxy cascade, then fallback to `python3 opencode/skills/read/scripts/fetch_weixin.py "{url}"` if blocked |
| `.pdf` URL or local PDF path | PDF extraction |
| Everything else | Run `bash opencode/skills/read/scripts/fetch.sh "{url}"` |

After choosing the route, load `references/read-methods.md` and follow the matching command exactly.

## Preview Format

Use this only when the user explicitly asks for preview output or when saving is skipped.

```text
Title:  {title}
Author: {author} (if available)
Source: {platform}
URL:    {original url}

Summary
{3-5 sentence summary}

Content
{full Markdown, truncated at 200 lines if long}
```

## Saving

Save to `~/Downloads/{title}.md` with YAML frontmatter by default.

Skip saving only if the user explicitly says `just preview` or `don't save`.

After saving and reporting the path, stop. Do not analyze, comment on, or discuss the content unless the user asks. If preview output was requested and truncated at 200 lines, say so and offer to continue.

## Notes

- `r.jina.ai` and `defuddle.md` do not require an API key.
- Commands above assume the current working directory is the repository root.
- If the environment uses a local proxy, pass it to `opencode/skills/read/scripts/fetch.sh` as the second argument.
- For long output, preview only the first 200 lines before deciding whether to continue.
- For GitHub URLs, prefer `gh` CLI if the task needs GitHub-specific metadata rather than rendered page content.
