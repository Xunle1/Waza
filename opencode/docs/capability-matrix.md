# OpenCode Capability Matrix

This matrix tracks the current OpenCode migration surface for Waza.

| Skill | Claude status | OpenCode status | Support level | Current note |
| :--- | :--- | :--- | :--- | :--- |
| `think` | Available in root `skills/think/` | Available in `opencode/skills/think/` | Formal | OpenCode version is already migrated. |
| `design` | Available in root `skills/design/` | Available in `opencode/skills/design/` | Formal | OpenCode version is already migrated. |
| `check` | Available in root `skills/check/` | Available in `opencode/skills/check/` | Formal, with guard downgrade | Review flow is migrated. Destructive-command screening is advisory unless the project adds an external wrapper or CI enforcement. |
| `hunt` | Available in root `skills/hunt/` | Available in `opencode/skills/hunt/` | Formal | OpenCode version is already migrated. |
| `learn` | Available in root `skills/learn/` | Available in `opencode/skills/learn/` | Formal | OpenCode version is already migrated. |
| `read` | Available in root `skills/read/` | Available in `opencode/skills/read/` | Formal | OpenCode version is already migrated. |
| `write` | Available in root `skills/write/` | Available in `opencode/skills/write/` | Formal | OpenCode version is already migrated. |
| `health` | Available in root `skills/health/` | Available in `opencode/skills/health/` | Formal, with shared-instruction scan | Layered audit is migrated to OpenCode semantics and also scans nearby repo instruction files when they can conflict with OpenCode behavior. |

## Notes

- Claude assets stay in the repository root.
- OpenCode assets stay inside `opencode/`.
- No shared cross-runtime directory is introduced in this phase.
- OpenCode skill frontmatter in this repo does not currently expose a proven hard command-intercept hook. Any destructive-command blocking documented by `check` is therefore advisory unless the surrounding environment adds its own enforcement.
- OpenCode statusline support in this repo is a fallback renderer plus manual hookup guidance, not a claimed verified native hook.
- OpenCode English coaching in this repo is a manual instruction template, not a claimed always-on injection point.

## Extras

| Asset | OpenCode support | Note |
| :--- | :--- | :--- |
| Statusline | Fallback only | `opencode/scripts/statusline.sh` preserves the Claude-style renderer, but `opencode/scripts/setup-statusline.sh` only stages a local script because a native OpenCode hookup point is not yet verified in this repo. |
| English coaching | Manual template | `opencode/templates/english-coaching.md` is written for OpenCode, but it must be pasted into whatever instruction surface the host actually provides. |
