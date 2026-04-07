# OpenCode Migration Design

## Summary

Add a first class OpenCode edition to this repository while preserving the current Claude Code edition and release flow. The OpenCode edition should live alongside the existing Claude assets, mirror Waza's current skill set as closely as the host allows, and honestly document any capability gaps instead of pretending to offer parity where the host cannot support it.

## Goals

- Keep the current Claude Code structure and distribution path working.
- Add an OpenCode edition in the same repository.
- Migrate all eight skills to OpenCode.
- Migrate install and usage docs for OpenCode.
- Migrate auxiliary capabilities when feasible, including statusline and English coaching.
- Preserve existing Waza product shape: one folder per skill, references and scripts living close to the skill that uses them, and lightweight packaging.
- Prefer high fidelity behavior over fast but shallow translation.

## Non-Goals

- Do not replace the existing Claude edition.
- Do not force both platforms to share one `SKILL.md` file.
- Do not introduce a `shared/` directory in the first version.
- Do not claim feature parity where OpenCode lacks an equivalent host capability.

## Repository Layout

The repository keeps its current Claude-oriented layout at the root and adds a complete OpenCode edition under `opencode/`.

```text
.
├── skills/                     # existing Claude edition
├── .claude-plugin/            # existing Claude marketplace metadata
├── install.sh                 # existing Claude installer
├── opencode/
│   ├── skills/
│   │   ├── think/
│   │   ├── design/
│   │   ├── check/
│   │   ├── hunt/
│   │   ├── learn/
│   │   ├── read/
│   │   ├── write/
│   │   └── health/
│   ├── scripts/
│   ├── templates/
│   ├── docs/
│   ├── README.md
│   └── install.sh
└── README.md
```

This keeps the platform boundary obvious. It accepts limited duplication in exchange for easier maintenance and clearer release behavior.

## Migration Tiers

### Near-port skills

These skills keep the same core workflow and user intent, with host-specific tool names and wording updated for OpenCode:

- `think`
- `design`
- `hunt`
- `learn`
- `write`

For these skills, fidelity comes from preserving trigger conditions, step ordering, stop conditions, and gotchas.

### Host-rebuild skills

These skills keep their product goal but require OpenCode-specific execution details:

- `read`
- `check`

`read` should still route URLs, PDFs, WeChat links, and Feishu links into clean Markdown output, but it must stop depending on Claude-specific runtime variables like `CLAUDE_SKILL_DIR`.

`check` should still operate as a disciplined review workflow with review-depth classification, specialist review, fix routing, and mandatory verification. The OpenCode version may need different implementation details for hooks, confirmations, and specialist execution depending on host support.

### Redefined skill

- `health`

The Claude version audits Claude-specific control surfaces such as `CLAUDE.md`, `.claude/settings.local.json`, hooks, and Claude-oriented skill installation. The OpenCode version should keep the same meta-goal, auditing whether the coding agent environment is healthy, but redefine the surfaces around OpenCode's actual configuration, tools, guards, subagents, and integrations.

## OpenCode Packaging

OpenCode gets its own installation and documentation entry points.

- Root `README.md` becomes a platform selector.
- `opencode/README.md` explains installation, usage, capability differences, and known limitations for OpenCode.
- `opencode/install.sh` installs only OpenCode assets and never writes to `~/.claude/*`.

This keeps user expectations aligned with the host they actually use.

## Auxiliary Capabilities

### Statusline

If OpenCode exposes a supported statusline or equivalent script hook, migrate the current feature with OpenCode-specific setup under `opencode/scripts/`.

If no equivalent integration point exists, provide the closest honest fallback, such as a standalone status output script, and mark it as a degraded implementation in OpenCode documentation.

### English coaching

If OpenCode exposes a stable prompt or rules injection point, provide an OpenCode-specific template under `opencode/templates/`.

If no such integration point exists, document a manual installation path instead of pretending automatic installation exists.

## Capability Reporting

The OpenCode edition should explicitly classify features by support level in `opencode/docs/capability-matrix.md`:

- fully aligned
- closely aligned
- degraded
- unsupported

This applies especially to:

- `check` hook-like behavior
- `check` specialist execution model
- `health` host inspection depth
- `statusline`
- `english coaching`

## Verification Strategy

The OpenCode edition should ship with its own verification guidance and, where feasible, scripts. Verification should cover:

- expected OpenCode skill directory layout exists
- referenced files under each skill exist
- install script paths are valid
- root and OpenCode README paths are accurate
- capability matrix is present and matches the documented behavior of complex skills and auxiliary features

## Risks

### Host capability mismatch

OpenCode may not expose exact equivalents for hooks, structured user prompts, subagent execution, global prompt injection, or statusline integration. This most directly affects `check`, `health`, `statusline`, and `english coaching`.

### Documentation drift across platforms

Once the repository has both Claude and OpenCode editions, content can drift. The chosen structure accepts some duplication to avoid the worse alternative of over-abstracted platform conditionals inside each skill.

### False parity claims

The main product risk is not incomplete migration, it is overstating parity. The OpenCode edition must document degraded behavior plainly whenever the host cannot support the Claude feature set exactly.

## Implementation Boundaries

The first implementation pass should produce:

- `opencode/` directory scaffolding
- eight OpenCode skill directories
- OpenCode install and README entry points
- migrated or redefined auxiliary capabilities where feasible
- explicit capability reporting for any non-parity areas

The first implementation pass does not need to solve every host gap perfectly, but it must leave no ambiguous placeholders. Every unsupported or degraded area should be stated explicitly.

## Acceptance Criteria

- Claude assets at the repository root continue to exist unchanged unless a doc needs platform-routing updates.
- `opencode/skills/` contains all eight skills.
- OpenCode has a dedicated install path and user documentation.
- `read`, `check`, and `health` each have explicit OpenCode-specific behavior, not placeholder text.
- Any migrated auxiliary feature is either working in OpenCode or clearly documented as degraded or manual.
- No `shared/` directory is introduced.

## Decision Summary

- Keep Claude and OpenCode as separate editions in one repository.
- Do not introduce a shared content layer in the first pass.
- Preserve Waza's one-skill-one-folder structure inside `opencode/skills/`.
- Preserve behavior for simple workflow skills and rebuild platform-bound skills around OpenCode's actual control surfaces.
- Prefer honest capability reporting over premature claims of parity.
