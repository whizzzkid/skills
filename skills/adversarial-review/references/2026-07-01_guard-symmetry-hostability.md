---
class: principle
---

**Rule** — For a parallel-guard-symmetry finding (sweep 2.27), first confirm each sibling can actually host a step-level shell command before flagging asymmetry. If a plugin owns the CI runner's `command` hook, the runner executes the hook, not any step-level command — a prepended guard there is inert. When a sibling cannot host the guard, check for an equivalent guard deeper in the shared path (entrypoint / install script) before demanding one at the step level.

**Why** — A reviewer raised a Major that a CI step lacked the `: "${VAR:?msg}"` guard its sibling release step had. The release step ran a raw `docker build` (guard runs); the CI step was driven by a build-mode compose/build plugin that implements the command hook itself, so a step-level guard would be silently ignored — and the real fail-fast already lived in the shared in-container install script. The symmetry sweep compared guard presence without checking whether each sibling could even host the guard.

**Where** — `wk-adversarial-review` Step 2 sweep 2.27 (Check + Fix columns).
