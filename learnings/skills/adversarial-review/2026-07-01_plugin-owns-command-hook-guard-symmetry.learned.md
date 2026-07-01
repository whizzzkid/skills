---
skill: wk-adversarial-review
date: 2026-07-01
type: pattern
severity: medium
---

A "missing fail-fast guard, asymmetric with its sibling" finding was a false
positive because the sibling step's build plugin owns the CI runner's command
hook, so a step-level guard command there would never execute.

**What happened:** An automated reviewer raised a Major that one CI build step
lacked the pipeline-level `: "${VAR:?msg}"` fail-fast guard its sibling release
step had (sweep 2.27 parallel-guard-symmetry shape). Investigation showed the two
steps use different build mechanisms: the release step runs a raw `docker build`
as its shell command (so a prepended guard runs), while the CI step is driven by
a build-mode compose/build plugin. That plugin implements the CI runner's
`command` hook itself — when a plugin owns the command hook, the runner executes
the hook, not any step-level command — so an added guard command would be
silently ignored, and the real fail-fast already lived one layer in (the shared
in-container install script's `:?` guard, before dependency install).

**Root cause:** The symmetry sweep compares guard presence across sibling steps
without checking whether each sibling can even host the guard. Two steps that look
parallel can dispatch their command through different mechanisms (raw shell vs. a
plugin-owned command hook); a guard is only attachable where the step's own
shell command actually runs.

**Suggested fix:** For a parallel-guard-symmetry finding across CI/build steps,
first confirm each sibling actually executes a step-level shell command. If a
plugin owns the runner's command hook (build-mode compose/build plugins do), a
step-level guard is inert there — downgrade the asymmetry finding and check
whether an equivalent guard already exists deeper in the shared path (entrypoint
/ install script) before demanding one at the step level.
