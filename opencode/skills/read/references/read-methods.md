# Read Methods Reference

## Proxy Cascade

Try in order. Success means non-empty output with readable content. If a proxy returns empty content, an error page, or fewer than 5 lines, treat it as failed and try the next one.

### 1. r.jina.ai

```bash
curl -sL "https://r.jina.ai/{url}"
```

Wide coverage, preserves image links. Try this first.

### 2. defuddle.md

```bash
curl -sL "https://defuddle.md/{url}"
```

Cleaner output with YAML frontmatter. Use it if `r.jina.ai` returns empty content or errors.

### 3. Local CLI fallback

```bash
defuddle parse "{url}" -m
```

Last resort if both hosted proxies fail and `defuddle` is installed locally. This must still return Markdown. If it cannot, fail instead of returning JSON.

## PDF to Markdown

### Remote PDF URL

`r.jina.ai` can handle PDF URLs directly:

```bash
curl -sL "https://r.jina.ai/{pdf_url}"
```

If that fails, download and extract locally:

```bash
curl -sL "{pdf_url}" -o /tmp/input.pdf
pdftotext -layout /tmp/input.pdf -
```

### Local PDF File

```bash
# Best quality, requires: pip install marker-pdf
marker_single /path/to/file.pdf --output_dir ~/Downloads/

# Fast for text-heavy PDFs, requires: brew install poppler
pdftotext -layout /path/to/file.pdf - | sed 's/\f/\n---\n/g'

# No-dependency fallback
python3 -c "
import pypdf, sys
r = pypdf.PdfReader(sys.argv[1])
print('\n\n'.join(p.extract_text() for p in r.pages))
" /path/to/file.pdf
```

Use `marker` when layout matters, such as papers or tables. Use `pdftotext` for speed.

## Feishu / Lark Document

Run the built-in script from the repository root. Requires `requests` and Feishu app credentials:

```bash
pip install requests
export FEISHU_APP_ID=your_app_id
export FEISHU_APP_SECRET=your_app_secret
python3 opencode/skills/read/scripts/fetch_feishu.py "{url}"
```

Supports `docx` documents and wiki pages that resolve to `docx` documents. Legacy `docs` URLs are not supported by this script. The Feishu app needs `docx:document:readonly` and `wiki:wiki:readonly` permissions.

Output: YAML frontmatter with title, document ID, and URL, followed by the Markdown body.

## WeChat Public Account

Try the proxy cascade first. It works for most public articles without extra tools.

If the proxy is blocked, use the built-in Playwright fallback from the repository root. It needs a one-time browser install:

```bash
pip install playwright beautifulsoup4 lxml
playwright install chromium
python3 opencode/skills/read/scripts/fetch_weixin.py "{url}"
```
