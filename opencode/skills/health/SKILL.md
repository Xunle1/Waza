---
name: health
description: Use when OpenCode ignores instructions, command guards feel weak, installed skills drift, or verification discipline is inconsistent. Audits the OpenCode control surface and nearby repo instruction files that can conflict with it.
version: 3.0.0
allowed-tools:
  - bash
  - read
  - glob
  - grep
---

# Health: Audit the OpenCode Control Surface

Audit the active OpenCode setup with the six-layer model:

`instructions -> rules -> installed skills -> command guards -> subagents -> verification tooling`

The goal is to find the broken layer in the OpenCode setup, and to flag nearby repo instruction files only when they can conflict with that setup.

## Step 0: Assess Project Tier

Choose the tier first, then apply only that tier's expectations.

| Tier | Signal | Expectation |
|------|--------|-------------|
| **Simple** | Small repo, one maintainer, little automation | One instruction source, few or no rules, skills optional |
| **Standard** | Team repo or CI present, multiple workflows | Clear instruction file, some rules, installed skills, basic guards, explicit verification |
| **Complex** | Multi-language, multiple contributors, heavy automation | Full six-layer setup with separation of intent, guards, delegation, and verification |

## Step 1: Collect Data

Collect the active OpenCode surface. Include adjacent repo instruction files only because they can conflict with OpenCode behavior in shared-agent repositories. Prefer one bash block so the evidence is captured together.

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.opencode/skills}"

printf '=== PROJECT ===\n'
printf 'root=%s\n' "$ROOT"
printf 'files=%s\n' "$(git -C "$ROOT" ls-files 2>/dev/null | wc -l | tr -d ' ')"
printf 'contributors=%s\n' "$(git -C "$ROOT" log -n 200 --format='%ae' 2>/dev/null | sort -u | wc -l | tr -d ' ')"
printf 'ci=%s\n' "$(ls "$ROOT/.github/workflows"/*.yml "$ROOT/.github/workflows"/*.yaml 2>/dev/null | wc -l | tr -d ' ')"

printf '\n=== INSTRUCTIONS ===\n'
for f in \
  "$ROOT/AGENTS.md" \
  "$ROOT/CLAUDE.md" \
  "$ROOT/GEMINI.md" \
  "$ROOT/.github/copilot-instructions.md"; do
  [ -f "$f" ] && { printf -- '--- %s ---\n' "$f"; sed -n '1,220p' "$f"; }
done

printf '\n=== RULES ===\n'
for d in \
  "$ROOT/rules" \
  "$ROOT/.cursor/rules" \
  "$ROOT/.github/instructions"; do
  [ -d "$d" ] && find "$d" -maxdepth 2 -type f | sort | while IFS= read -r f; do
    printf -- '--- %s ---\n' "$f"
    sed -n '1,160p' "$f"
  done
done
[ -f "$ROOT/.windsurfrules" ] && { printf -- '--- %s ---\n' "$ROOT/.windsurfrules"; sed -n '1,160p' "$ROOT/.windsurfrules"; }

printf '\n=== INSTALLED SKILLS ===\n'
[ -d "$SKILLS_DIR" ] && find -L "$SKILLS_DIR" -maxdepth 3 -name 'SKILL.md' | sort | while IFS= read -r f; do
  printf 'path=%s words=%s\n' "$f" "$(wc -w < "$f" | tr -d ' ')"
  sed -n '1,12p' "$f"
done

printf '\n=== COMMAND GUARDS ===\n'
for f in \
  "$ROOT/opencode/scripts/verify.sh" \
  "$ROOT/opencode/skills/check/scripts/check-destructive.sh"; do
  [ -f "$f" ] && { printf -- '--- %s ---\n' "$f"; sed -n '1,200p' "$f"; }
done

printf '\n=== SUBAGENT SURFACE ===\n'
find "$ROOT/opencode/skills" -path '*/agents/*.md' -type f 2>/dev/null | sort | while IFS= read -r f; do
  printf -- '--- %s ---\n' "$f"
  sed -n '1,200p' "$f"
done

printf '\n=== VERIFICATION TOOLING ===\n'
[ -f "$ROOT/package.json" ] && sed -n '1,220p' "$ROOT/package.json"
[ -f "$ROOT/Makefile" ] && sed -n '1,220p' "$ROOT/Makefile"
[ -f "$ROOT/pyproject.toml" ] && sed -n '1,220p' "$ROOT/pyproject.toml"
find "$ROOT/.github/workflows" -maxdepth 1 -type f 2>/dev/null | sort | while IFS= read -r f; do
  printf -- '--- %s ---\n' "$f"
  sed -n '1,200p' "$f"
done
```

Do not fail the audit just because another runtime's path is absent. Only flag non-OpenCode files when they create conflicting instructions, duplicated policy, or misleading control assumptions for the OpenCode workflow.

## Step 2: Analyze by Layer

Work top-down. For each finding, identify the highest layer where the problem can be fixed cleanly.

### Layer 1: Instructions

Check the instruction source OpenCode will actually inherit for this workspace.

- Is there one clear primary instruction file?
- Are commands, verification expectations, and output constraints executable rather than narrative?
- Are there conflicting instruction files that can send different signals?

### Layer 2: Rules

Rules are optional for Simple projects and expected for Standard or Complex setups.

- Path- or tool-specific policy belongs here, not crammed into the primary instruction file
- Rules should narrow behavior, not restate the entire operating manual
- Flag duplicates and contradictions across rule locations

### Layer 3: Installed Skills

- Installed skills in `OPENCODE_SKILLS_DIR` should have narrow descriptions and valid frontmatter
- Skills should teach workflows, not hide policy that should be always-on elsewhere
- Flag missing versions, broken references, obvious injection text, or skill descriptions so broad they will misfire

### Layer 4: Command Guards

- Audit shell wrappers, review preflights, and CI or script gates that prevent unsafe commands or missing verification
- Distinguish hard enforcement from advisory checks
- If the project depends on a guard that only exists as documentation, mark it as fragile

### Layer 5: Subagents

- Review any agent prompts or delegated reviewer prompts under `opencode/skills/**/agents/`
- Delegated work should constrain scope, output shape, and confidence threshold
- Flag free-form subagent prompts that can dump narrative back into the parent context with no structure

### Layer 6: Verification Tooling

- A claimed done-state must map to an actual command, script, or CI check in this repo
- Flag verification text with no runnable command behind it
- Prefer one obvious local verification entry point for recurring workflows

## Specialist Split

When the repo is Standard or Complex, use two analysis tracks in parallel if the tooling supports it:

- `agents/agent1-context.md` for instructions, rules, installed skills, and verification surface
- `agents/agent2-control.md` for command guards, subagents, and enforcement quality

If parallel delegation is unavailable, run both checklists locally and say so.

## Severity Routing

Use these labels:

- `[!] Critical`: instruction conflicts, unsafe command paths, missing verification gate for declared done-states, unusable installed skills
- `[~] Structural`: wrong content in the wrong layer, weak advisory-only controls where stronger controls are assumed, oversized or duplicate rules
- `[-] Incremental`: cleanup, compression, naming, provenance, or guidance tuning

## Report Shape

```text
Health Report: {project}
Tier: simple / standard / complex

[PASS]
- relevant checks that are healthy

[!]
- critical findings with layer ownership

[~]
- structural findings with layer ownership

[-]
- incremental findings with layer ownership
```

End by asking whether to draft fixes, grouped by layer.
