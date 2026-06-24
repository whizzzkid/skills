---
class: principle
---

**Rule:** Before treating a local test/command failure as a PR finding: (1) check
whether the failing line is in the diff — a failure far from changed lines is a
strong tell it is environmental; (2) confirm the interpreter/runtime matches the
project's pinned version (`mise`/`.tool-versions`/CI config), not whatever is first
on `PATH`; (3) re-run under the pinned version before reporting.

**Why:** A pre-existing environment incompatibility (e.g. a host default interpreter
older than the project's required runtime) produces failures far from the diff that
look like a PR-introduced regression and nearly become false blockers. CI runs the
pinned runtime; local `PATH` may not.

**Where:** Phase 3 "Discriminate environmental failures from PR findings"; mirrors
the `wk-adversarial-review` runtime matrix ("run every interpreter the diff
exercises, not whatever is first on PATH").
