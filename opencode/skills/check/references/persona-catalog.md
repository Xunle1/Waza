# Specialist Reviewer Activation Catalog

The orchestrator reads the full diff and uses judgment, not keyword matching, to decide which specialists should activate.

## Always-On

The base `check` review always runs. Specialists are additive.

## Conditional Specialists

### Security Reviewer

**Agent file:** `agents/reviewer-security.md`
**Activate at:** Standard or Deep depth

Activate when the diff touches:

- authentication, authorization, or session logic
- untrusted input flowing into commands, queries, templates, or paths
- filesystem writes on user-controlled or externally-derived paths
- shell or subprocess execution
- secret handling, tokens, or credential storage
- raw SQL, migration code, or data repair paths
- imported web content, API output, or subagent output promoted into a trusted action

Do not activate for pure presentation work, copy changes, or test-only edits with no new trust boundary.

### Architecture Reviewer

**Agent file:** `agents/reviewer-architecture.md`
**Activate at:** Standard or Deep depth

Activate when the diff:

- adds or removes a module, package, skill, or service boundary
- changes a public API, exported type, command contract, or configuration interface
- introduces a new cross-directory dependency
- modifies workflow composition across multiple files or directories
- adds, removes, or reclassifies a significant dependency
- rewrites execution order, verification flow, or control handoff between layers

Do not activate for single-file fixes, narrow test additions, or wording-only documentation edits.

## Adversarial Pass

No separate agent. The orchestrator performs this pass after normal review and specialist review merge.

**Activate at:** Deep depth only, or earlier if the diff touches command execution, destructive actions, auth, deployment, or user data mutation.

Four angles:

1. **Assumption violation**: what input, ordering, or invariant is assumed to hold?
2. **Composition failure**: what breaks when this change interacts with existing automation or concurrent work?
3. **Cascade construction**: what valid sequence of steps lands the system in an invalid state?
4. **Abuse case**: what happens on repeated retries, large inputs, or operator error?

Report only concrete scenarios. Suppress findings below 0.60 confidence.
