# Waza for OpenCode

This directory contains the OpenCode runtime variant of Waza.

## Install

Install the eight OpenCode skills into the default OpenCode skills directory:

```bash
bash opencode/install.sh
```

By default this links skills into `~/.opencode/skills`. Override with `OPENCODE_SKILLS_DIR` if your setup uses another location.

## What Is Included

- Install entry: `opencode/install.sh`
- Verification entry: `opencode/scripts/verify.sh`
- Capability matrix: `opencode/docs/capability-matrix.md`
- Skills: `opencode/skills/{think,design,check,hunt,learn,read,write,health}`
- OpenCode statusline fallback assets: `opencode/scripts/statusline.sh`, `opencode/scripts/setup-statusline.sh`
- OpenCode English coaching manual template: `opencode/templates/english-coaching.md`

## Skill List

| Skill | Purpose |
| :--- | :--- |
| `think` | Design and pressure-test before building. |
| `design` | Produce production-grade frontend UI direction. |
| `check` | Review diffs, verify changes, and warn on destructive commands. |
| `hunt` | Debug systematically before applying fixes. |
| `learn` | Research unfamiliar domains into structured output. |
| `read` | Fetch URLs or PDFs into cleaner Markdown. |
| `write` | Rewrite prose naturally in Chinese and English. |
| `health` | Audit the surrounding OpenCode setup and instructions. |

## Capability Matrix

See [`opencode/docs/capability-matrix.md`](docs/capability-matrix.md) for the skill-by-skill support level and runtime notes.

## Downgrade Points

OpenCode support is intentionally honest about gaps:

- Skill content is migrated and installable.
- `check` can warn about destructive commands, but this repo does not claim a proven hard command-intercept hook in OpenCode. Enforcement remains advisory unless your environment adds its own wrapper or CI gate.
- Statusline keeps the Claude-style display shape, but this repo does not currently document a verified native OpenCode statusline hook. The provided setup script only stages a renderer and prints manual hookup guidance.
- English coaching is shipped as a manual prompt template. If your OpenCode host does not provide a stable global instruction injection point, append or paste it into your own session or profile configuration.

## Optional Extras

Stage the statusline renderer locally:

```bash
bash opencode/scripts/setup-statusline.sh
```

This installs `~/.opencode/statusline.sh` and prints fallback instructions. It does not modify an OpenCode config file because that integration point is not yet verified here.

For English coaching, copy the template from `opencode/templates/english-coaching.md` into the instruction surface your OpenCode host actually supports.

## Verify

```bash
bash opencode/scripts/verify.sh
```
