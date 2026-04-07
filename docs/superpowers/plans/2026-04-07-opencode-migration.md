# OpenCode Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class OpenCode edition to Waza with all eight skills, OpenCode-specific docs and installers, and the closest honest adaptation of statusline and English coaching.

**Architecture:** Keep the existing Claude edition at the repository root and add a parallel OpenCode edition under `opencode/`. Port workflow-heavy skills with close wording changes, rebuild host-bound skills around OpenCode semantics, and make capability gaps explicit in OpenCode docs instead of hiding them.

**Tech Stack:** Markdown skill files, bash installers, existing Python/bash helper scripts, git-based verification, repository docs under `docs/superpowers/`

---

## File Structure

### New OpenCode root

- Create: `opencode/README.md`
- Create: `opencode/install.sh`
- Create: `opencode/docs/capability-matrix.md`
- Create: `opencode/scripts/verify.sh`
- Create: `opencode/scripts/statusline.sh`
- Create: `opencode/scripts/setup-statusline.sh`
- Create: `opencode/templates/english-coaching.md`

### New OpenCode skills

- Create: `opencode/skills/think/SKILL.md`
- Create: `opencode/skills/design/SKILL.md`
- Create: `opencode/skills/design/references/design-reference.md`
- Create: `opencode/skills/hunt/SKILL.md`
- Create: `opencode/skills/learn/SKILL.md`
- Create: `opencode/skills/write/SKILL.md`
- Create: `opencode/skills/write/references/write-zh.md`
- Create: `opencode/skills/write/references/write-en.md`
- Create: `opencode/skills/read/SKILL.md`
- Create: `opencode/skills/read/references/read-methods.md`
- Create: `opencode/skills/read/scripts/fetch.sh`
- Create: `opencode/skills/read/scripts/fetch_feishu.py`
- Create: `opencode/skills/read/scripts/fetch_weixin.py`
- Create: `opencode/skills/check/SKILL.md`
- Create: `opencode/skills/check/references/persona-catalog.md`
- Create: `opencode/skills/check/agents/reviewer-security.md`
- Create: `opencode/skills/check/agents/reviewer-architecture.md`
- Create: `opencode/skills/check/scripts/check-destructive.sh`
- Create: `opencode/skills/check/scripts/verify.sh`
- Create: `opencode/skills/health/SKILL.md`
- Create: `opencode/skills/health/agents/agent1-context.md`
- Create: `opencode/skills/health/agents/agent2-control.md`

### Existing files to modify

- Modify: `README.md`
- Modify: `.gitignore`
- Modify: `CLAUDE.md` only if verification docs need OpenCode notes and the update remains repository-scoped

### Supporting specs and plans

- Existing spec: `docs/superpowers/specs/2026-04-07-opencode-migration-design.md`
- This plan: `docs/superpowers/plans/2026-04-07-opencode-migration.md`

### Task 1: Scaffold OpenCode Edition

**Files:**
- Create: `opencode/README.md`
- Create: `opencode/install.sh`
- Create: `opencode/docs/capability-matrix.md`
- Create: `opencode/scripts/verify.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Create the OpenCode directory layout**

```bash
mkdir -p opencode/docs opencode/scripts opencode/templates \
  opencode/skills/{think,design,hunt,learn,write,read,check,health} \
  opencode/skills/design/references \
  opencode/skills/write/references \
  opencode/skills/read/{references,scripts} \
  opencode/skills/check/{references,agents,scripts} \
  opencode/skills/health/agents
```

- [ ] **Step 2: Add OpenCode paths to `.gitignore` only if local runtime artifacts are introduced**

```gitignore
# OpenCode local runtime state
.opencode/
```

- [ ] **Step 3: Write the OpenCode capability matrix**

```md
# OpenCode Capability Matrix

| Area | Status | Notes |
| :--- | :--- | :--- |
| think/design/hunt/learn/write | fully aligned | Workflow preserved with OpenCode tool naming |
| read | closely aligned | Same routing, OpenCode-local script paths |
| check | closely aligned | Review flow preserved, host guard behavior depends on OpenCode hooks |
| health | degraded | Rebuilt around OpenCode control surfaces instead of Claude config files |
| statusline | degraded or fully aligned | Depends on OpenCode statusline integration point |
| english coaching | degraded or fully aligned | Depends on OpenCode prompt injection support |
```

- [ ] **Step 4: Write the OpenCode installer**

```bash
#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.opencode/skills}"

mkdir -p "$SKILLS_DIR"

for dir in "$ROOT"/skills/*/; do
  name=$(basename "$dir")
  ln -sfn "$dir" "$SKILLS_DIR/$name"
  echo "linked: $name -> $SKILLS_DIR/$name"
done
```

- [ ] **Step 5: Write the OpenCode verifier**

```bash
#!/bin/bash
set -euo pipefail

test -f opencode/README.md
test -f opencode/install.sh
test -f opencode/docs/capability-matrix.md

for skill in think design check hunt write learn read health; do
  test -f "opencode/skills/$skill/SKILL.md"
done

echo "opencode layout: ok"
```

- [ ] **Step 6: Run the verifier and confirm the initial scaffold passes**

Run: `bash opencode/scripts/verify.sh`
Expected: `opencode layout: ok`

- [ ] **Step 7: Commit the scaffold**

```bash
git add .gitignore opencode/README.md opencode/install.sh opencode/docs/capability-matrix.md opencode/scripts/verify.sh opencode/skills
git commit -m "feat: scaffold opencode edition"
```

### Task 2: Port `think`, `design`, and `hunt`

**Files:**
- Create: `opencode/skills/think/SKILL.md`
- Create: `opencode/skills/design/SKILL.md`
- Create: `opencode/skills/design/references/design-reference.md`
- Create: `opencode/skills/hunt/SKILL.md`
- Source references: `skills/think/SKILL.md`, `skills/design/SKILL.md`, `skills/design/references/design-reference.md`, `skills/hunt/SKILL.md`
- Test: `opencode/scripts/verify.sh`

- [ ] **Step 1: Copy the source files into the OpenCode skill tree**

```bash
cp skills/think/SKILL.md opencode/skills/think/SKILL.md
cp skills/design/SKILL.md opencode/skills/design/SKILL.md
cp skills/design/references/design-reference.md opencode/skills/design/references/design-reference.md
cp skills/hunt/SKILL.md opencode/skills/hunt/SKILL.md
```

- [ ] **Step 2: Rewrite tool names and host wording in `think`**

```yaml
allowed-tools:
  - bash
  - read
  - glob
  - grep
  - webfetch
```

```md
Before implementation, verify the relevant OpenCode tools are available in this session. If a required external CLI such as `gh` is part of the plan, confirm it is installed before depending on it.
```

- [ ] **Step 3: Rewrite `design` to use OpenCode terminology instead of Claude-specific tool names**

```md
Ask one clarifying question at a time in the conversation before drafting the visual direction. Use the available filesystem and shell tools directly instead of referring to Claude-only tools by name.
```

- [ ] **Step 4: Rewrite `hunt` to preserve the root-cause-first rule while removing Claude-only references**

```md
Do not edit code until you can state the root cause in one sentence and back it with evidence from reproduction, logs, or code flow.
```

- [ ] **Step 5: Run verification after the three skills exist and reference paths are valid**

Run: `bash opencode/scripts/verify.sh`
Expected: `opencode layout: ok`

- [ ] **Step 6: Commit the first skill batch**

```bash
git add opencode/skills/think opencode/skills/design opencode/skills/hunt
git commit -m "feat: port opencode planning skills"
```

### Task 3: Port `learn` and `write`

**Files:**
- Create: `opencode/skills/learn/SKILL.md`
- Create: `opencode/skills/write/SKILL.md`
- Create: `opencode/skills/write/references/write-zh.md`
- Create: `opencode/skills/write/references/write-en.md`
- Source references: `skills/learn/SKILL.md`, `skills/write/SKILL.md`, `skills/write/references/write-zh.md`, `skills/write/references/write-en.md`
- Test: `opencode/scripts/verify.sh`

- [ ] **Step 1: Copy the source files into OpenCode**

```bash
cp skills/learn/SKILL.md opencode/skills/learn/SKILL.md
cp skills/write/SKILL.md opencode/skills/write/SKILL.md
cp skills/write/references/write-zh.md opencode/skills/write/references/write-zh.md
cp skills/write/references/write-en.md opencode/skills/write/references/write-en.md
```

- [ ] **Step 2: Replace slash-command references inside `learn` with OpenCode skill invocation wording**

```md
When the workflow reaches the reading phase, invoke the OpenCode `read` skill if the material is a URL or PDF. When the workflow reaches prose refinement, invoke the OpenCode `write` skill.
```

- [ ] **Step 3: Rewrite `write` frontmatter to match OpenCode semantics while preserving the same editing rules**

```yaml
name: write
description: Invoke only when explicitly asked to write, edit, or polish prose in Chinese or English.
version: 3.0.0
```

- [ ] **Step 4: Keep the body of `write` intact except for host-specific wording**

```md
输出修改后的内容后，停止。除非用户主动询问，否则不解释改动。
```

- [ ] **Step 5: Run verification for the second skill batch**

Run: `bash opencode/scripts/verify.sh`
Expected: `opencode layout: ok`

- [ ] **Step 6: Commit the second skill batch**

```bash
git add opencode/skills/learn opencode/skills/write
git commit -m "feat: port opencode learning and writing skills"
```

### Task 4: Rebuild `read`

**Files:**
- Create: `opencode/skills/read/SKILL.md`
- Create: `opencode/skills/read/references/read-methods.md`
- Create: `opencode/skills/read/scripts/fetch.sh`
- Create: `opencode/skills/read/scripts/fetch_feishu.py`
- Create: `opencode/skills/read/scripts/fetch_weixin.py`
- Source references: `skills/read/SKILL.md`, `skills/read/references/read-methods.md`, `skills/read/scripts/fetch.sh`, `skills/read/scripts/fetch_feishu.py`, `skills/read/scripts/fetch_weixin.py`
- Test: `opencode/scripts/verify.sh`

- [ ] **Step 1: Copy the existing read assets**

```bash
cp skills/read/SKILL.md opencode/skills/read/SKILL.md
cp skills/read/references/read-methods.md opencode/skills/read/references/read-methods.md
cp skills/read/scripts/fetch.sh opencode/skills/read/scripts/fetch.sh
cp skills/read/scripts/fetch_feishu.py opencode/skills/read/scripts/fetch_feishu.py
cp skills/read/scripts/fetch_weixin.py opencode/skills/read/scripts/fetch_weixin.py
chmod +x opencode/skills/read/scripts/fetch.sh
```

- [ ] **Step 2: Rewrite runtime path references in the read docs and skill file**

```md
Use `opencode/skills/read/scripts/fetch.sh` for the generic fetch path and the sibling Python scripts for Feishu and WeChat handling. Do not rely on `CLAUDE_SKILL_DIR`.
```

- [ ] **Step 3: Preserve the save behavior and explicit stop condition**

```md
Save to `~/Downloads/{title}.md` by default unless the user explicitly asks for preview only. After reporting the saved path, stop.
```

- [ ] **Step 4: Extend the verifier to check read references and scripts**

```bash
test -f opencode/skills/read/references/read-methods.md
test -f opencode/skills/read/scripts/fetch.sh
test -f opencode/skills/read/scripts/fetch_feishu.py
test -f opencode/skills/read/scripts/fetch_weixin.py
```

- [ ] **Step 5: Run verification for `read`**

Run: `bash opencode/scripts/verify.sh`
Expected: `opencode layout: ok`

- [ ] **Step 6: Commit the read migration**

```bash
git add opencode/skills/read opencode/scripts/verify.sh
git commit -m "feat: port opencode read skill"
```

### Task 5: Rebuild `check` and `health`

**Files:**
- Create: `opencode/skills/check/SKILL.md`
- Create: `opencode/skills/check/references/persona-catalog.md`
- Create: `opencode/skills/check/agents/reviewer-security.md`
- Create: `opencode/skills/check/agents/reviewer-architecture.md`
- Create: `opencode/skills/check/scripts/check-destructive.sh`
- Create: `opencode/skills/check/scripts/verify.sh`
- Create: `opencode/skills/health/SKILL.md`
- Create: `opencode/skills/health/agents/agent1-context.md`
- Create: `opencode/skills/health/agents/agent2-control.md`
- Source references: `skills/check/**`, `skills/health/**`
- Test: `opencode/scripts/verify.sh`

- [ ] **Step 1: Copy the Claude-oriented assets into the OpenCode tree as a starting point**

```bash
cp skills/check/SKILL.md opencode/skills/check/SKILL.md
cp skills/check/references/persona-catalog.md opencode/skills/check/references/persona-catalog.md
cp skills/check/agents/reviewer-security.md opencode/skills/check/agents/reviewer-security.md
cp skills/check/agents/reviewer-architecture.md opencode/skills/check/agents/reviewer-architecture.md
cp skills/check/scripts/check-destructive.sh opencode/skills/check/scripts/check-destructive.sh
cp skills/check/scripts/verify.sh opencode/skills/check/scripts/verify.sh
cp skills/health/SKILL.md opencode/skills/health/SKILL.md
cp skills/health/agents/agent1-context.md opencode/skills/health/agents/agent1-context.md
cp skills/health/agents/agent2-control.md opencode/skills/health/agents/agent2-control.md
chmod +x opencode/skills/check/scripts/check-destructive.sh opencode/skills/check/scripts/verify.sh
```

- [ ] **Step 2: Rewrite `check` around OpenCode tool names while preserving the review state machine**

```md
Read the diff, classify review depth, run specialist review when the host supports it, route findings by severity, and do not claim done until verification has run in this session.
```

- [ ] **Step 3: Replace Claude-only hook variables with OpenCode-specific guard behavior or explicit degraded wording**

```md
If OpenCode exposes command guards or tool hooks, connect `check-destructive.sh` through that mechanism. If not, document the destructive-command check as a manual review gate and mark it degraded in the capability matrix.
```

- [ ] **Step 4: Rewrite `health` to inspect OpenCode control surfaces instead of `.claude/*` paths**

```md
Audit the OpenCode environment through six layers: instructions, local rules, installed skills, command guards, subagent capabilities, and verification tooling.
```

- [ ] **Step 5: Update the capability matrix to record exact support status for `check` and `health`**

```md
| check hook enforcement | degraded | Manual gate unless OpenCode exposes hook interception |
| health config audit | closely aligned | Same six-layer audit goal, OpenCode-specific inspection targets |
```

- [ ] **Step 6: Extend the verifier to check check/health assets**

```bash
test -f opencode/skills/check/references/persona-catalog.md
test -f opencode/skills/check/agents/reviewer-security.md
test -f opencode/skills/check/agents/reviewer-architecture.md
test -f opencode/skills/check/scripts/check-destructive.sh
test -f opencode/skills/check/scripts/verify.sh
test -f opencode/skills/health/agents/agent1-context.md
test -f opencode/skills/health/agents/agent2-control.md
```

- [ ] **Step 7: Run verification for the complex skills**

Run: `bash opencode/scripts/verify.sh`
Expected: `opencode layout: ok`

- [ ] **Step 8: Commit the complex skills**

```bash
git add opencode/skills/check opencode/skills/health opencode/docs/capability-matrix.md opencode/scripts/verify.sh
git commit -m "feat: port opencode review and health skills"
```

### Task 6: Migrate Docs and Auxiliary Features

**Files:**
- Modify: `README.md`
- Create: `opencode/README.md`
- Create: `opencode/scripts/statusline.sh`
- Create: `opencode/scripts/setup-statusline.sh`
- Create: `opencode/templates/english-coaching.md`
- Modify: `opencode/docs/capability-matrix.md`
- Test: `opencode/scripts/verify.sh`

- [ ] **Step 1: Rewrite the root README as a platform entry page**

```md
## Platforms

### Claude Code

Use the existing skills under `skills/`.

### OpenCode

Use the OpenCode edition under `opencode/`.
See `opencode/README.md` for installation and capability notes.
```

- [ ] **Step 2: Write `opencode/README.md` with installation, usage, and capability notes**

```md
## Install

Run `bash opencode/install.sh`.

## Skills

- `think`
- `design`
- `check`
- `hunt`
- `write`
- `learn`
- `read`
- `health`

## Capability Matrix

See `opencode/docs/capability-matrix.md`.
```

- [ ] **Step 3: Create an OpenCode statusline script with the same quota-focused output shape when the host provides status payloads**

```bash
#!/bin/bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for the OpenCode statusline script" >&2
  exit 1
fi

cat | bash scripts/statusline.sh
```

- [ ] **Step 4: Adapt statusline setup for OpenCode or document the fallback clearly**

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "If OpenCode exposes a statusline command hook, point it to: bash $SCRIPT_DIR/statusline.sh"
echo "If OpenCode does not expose one, run: bash $SCRIPT_DIR/statusline.sh"
```

- [ ] **Step 5: Add an OpenCode English coaching template**

```md
## English Coaching

Apply passive grammar and phrasing correction to the user's English when the host supports persistent instruction templates. If the host does not support automatic injection, copy this block into the user's OpenCode global instructions manually.
```

- [ ] **Step 6: Extend verification to cover the OpenCode statusline and template assets**

```bash
test -f opencode/scripts/statusline.sh
test -f opencode/scripts/setup-statusline.sh
test -f opencode/templates/english-coaching.md
```

- [ ] **Step 7: Run final OpenCode verification**

Run: `bash opencode/scripts/verify.sh`
Expected: `opencode layout: ok`

- [ ] **Step 8: Run repository verification for the updated documentation and assets**

Run: `for f in skills/*/SKILL.md; do head -5 "$f" | grep -q "^name:" && echo "ok: $f" || echo "MISSING name: $f"; done`
Expected: `ok:` line for each root Claude skill

- [ ] **Step 9: Commit the OpenCode rollout docs and extras**

```bash
git add README.md opencode/README.md opencode/scripts/statusline.sh opencode/scripts/setup-statusline.sh opencode/templates/english-coaching.md opencode/docs/capability-matrix.md opencode/scripts/verify.sh
git commit -m "feat: document opencode edition"
```

## Self-Review

- Spec coverage: this plan covers the OpenCode directory layout, all eight skills, install/docs changes, statusline, English coaching, and capability reporting.
- Placeholder scan target strings: `TBD`, `TODO`, `implement later`, `similar to`, `as needed`.
- Type and naming consistency: every task uses the same `opencode/` root and the same eight skill names.
