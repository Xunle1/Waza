---
name: check
description: Use after implementation work or before merging in OpenCode. Reviews the diff first, scales depth by risk, routes findings by action level, and requires verification before sign-off.
version: 3.0.0
allowed-tools:
  - bash
  - read
  - grep
  - glob
  - apply_patch
---

# Check: Review Before You Ship

Read the diff, find the problems, fix what is safe, batch anything judgment-heavy, and do not claim done until verification has run in this session.

## Control Model

OpenCode skills do not provide a guaranteed pre-command hook that can hard-block destructive shell commands from inside this skill.

Treat `bash opencode/skills/check/scripts/check-destructive.sh "<command>"` as an advisory preflight, not an enforcement boundary. If the workflow needs hard blocking, the project must add an external wrapper, shell guard, or CI policy outside this skill.

## Get the Diff

Start with the review surface, not the implementation story.

```bash
git fetch origin
git diff origin/main
```

If the base branch is not `main`, ask before running. If already on the base branch, stop and ask which commits or range should be reviewed.

## Scope the Review

Count the diff and classify the review depth before reading details.

```bash
git diff origin/main --stat
```

| Depth | Criteria | Reviewers |
|-------|----------|-----------|
| **Quick** | Under 100 lines, 1-5 files, low-risk surface | Base review only |
| **Standard** | 100-500 lines, 6-10 files, or moderate integration risk | Base review plus conditional specialists |
| **Deep** | 500+ lines, 10+ files, or touches auth, data mutation, deployment, or command execution | Base review plus all relevant specialists and adversarial pass |

State the depth in one line before continuing.

## Did We Build What Was Asked?

Before inspecting code line by line:

- Read recent commit messages and any task artifact the user referenced.
- Label the change: `on target`, `drift`, or `incomplete`.
- Note scope drift, but do not let it hide correctness issues.

## Base Review

Hard stops, fix before sign-off:

- Injection risk: SQL, shell, path, templating, or command construction with untrusted input
- Auth and permission gaps, especially checks moved after side effects
- Shared-state races, unsafe check-then-act flows, missing locks or transactional boundaries
- External trust mistakes: web content, API output, tool output, or subagent output treated as authoritative without validation
- New identifiers, files, or config keys that do not exist outside the diff and were likely invented incorrectly
- Dependency additions or major version bumps that are not clearly required by the diff
- Behavior-changing automation presented as safe without explicit user confirmation

Soft signals, note but do not block by themselves:

- Surprising side effects not obvious from the function name or call site
- Untested new paths
- Magic literals, stale comments, dead code, or local style drift
- Fixed bottlenecks, unbounded growth, or repeated work that will compound under load

## Specialist Review

Load `references/persona-catalog.md` and decide which specialists activate from the actual diff, not from keywords alone.

Standard and Deep reviews should consider specialist passes for:

- `security`, when the diff changes trust boundaries, auth, secret handling, command execution, filesystem writes, raw queries, or external content ingestion
- `architecture`, when the diff changes module boundaries, public contracts, dependency direction, workflow composition, or project structure

If OpenCode subagents are available, launch the activated reviewers in parallel with the full diff and the matching prompt from `agents/`.

If subagents are unavailable, run the same prompts locally and say so in the sign-off.

After specialist passes:

- Deduplicate overlapping findings
- Keep the highest-severity phrasing for the same root issue
- Raise priority when multiple reviewers converge on the same defect

## Findings Routing

Classify every finding before editing or presenting it.

| Class | Meaning | Action |
|-------|---------|--------|
| `safe` | Unambiguous, low-risk correction | Apply immediately |
| `gated` | Likely correct but changes behavior or workflow | Batch into one user confirmation block |
| `manual` | Needs design or product judgment | Present as a decision, do not auto-apply |
| `advisory` | Useful note, no code change required now | Record in sign-off |

Rules:

- Apply `safe` items before presenting the review.
- Batch all `gated` items into one question, never one prompt per item.
- Keep `manual` and `advisory` separate so the user can see what actually blocks completion.

## Adversarial Pass

Deep reviews need one focused adversarial pass after standard review and specialist review merge.

Ask:

1. What assumption can fail here?
2. What breaks under concurrency or partial failure?
3. What valid sequence leads to an invalid state?
4. What can be abused at scale, during deploy, or through repeated retries?

Suppress vague findings. Keep only scenarios with a concrete exploit or failure path.

## Verification Gate

No sign-off without verification evidence from this session.

Run the project verification command if the repo already defines one. Otherwise run:

```bash
bash opencode/skills/check/scripts/verify.sh
```

If the script cannot detect a verification command, stop and ask the user what command should serve as the gate.

Done means:

- verification command ran in this session
- it passed
- you can quote the exact command and outcome

Anything weaker is not done.

## Sign-off

```text
files changed:    N (+X -Y)
scope:            on target / drift / incomplete
review depth:     quick / standard / deep
hard stops:       N found, N fixed, N deferred
signals:          N noted
specialists:      security / architecture / none
verification:     [command] -> pass / fail
control note:     advisory preflight only / external guard present
```
