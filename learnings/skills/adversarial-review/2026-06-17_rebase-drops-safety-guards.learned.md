---
skill: wk-adversarial-review
date: 2026-06-17
type: correction
severity: high
---

Rebase conflict resolution silently drops safety-critical guard calls even when the code compiles and all tests pass.

**What happened:** A `git rebase --onto` conflict on `cmd_local.go` had two sides: HEAD (base code) with `signal.Stop(sigCh)` after a function call, and the incoming commit without it. Conflict was resolved by taking the incoming commit's call site, which dropped `signal.Stop`. The drop was not caught by compilation or tests — the code worked, but a post-success SIGINT could still trigger `os.Exit(1)` on a successfully-completed run.

**Root cause:** The mechanical sweep catalog (2.44) covers call-site arg count mismatches after rebase conflicts but does not include a "safety guard presence audit" step. When resolving a conflict by choosing one side over the other, the reviewer needs to identify which lines on the *losing* side were intentional safety measures (not incidental code) and verify they survive in the merged result. A line like `signal.Stop(sigCh)` reads as boilerplate but embeds a safety contract; the comment explaining it was on a different line and easy to overlook.

**Suggested fix:** Add a sweep step: after resolving any `git rebase` conflict that touched a function call site, grep the conflict's HEAD side for calls to signal/context/cleanup primitives (`signal.Stop`, `context.Cancel`, `sync.*`, `defer`, `close(`, `os.RemoveAll`) that do *not* appear in the resolved result. Each absent primitive is a candidate blocker — verify the omission was intentional (the incoming commit explicitly removed it) versus accidental (the conflict resolution discarded it). Reference the git commit message and the original comment explaining the guard before declaring it safe to drop.
