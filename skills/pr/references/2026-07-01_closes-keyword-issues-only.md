---
class: principle
---

**Rule:** `Closes`/`Fixes`/`Resolves #N` auto-close only issues on merge — a
`#N` reference to a PR renders as a link but never auto-closes that PR. To
auto-close superseded PRs on merge, use a close-on-merge Action or post close
comments; keep the keyword as supersession documentation only.

**Why:** A combined dependency PR used `Closes #N` expecting the superseded
dependency PRs to auto-close on merge; GitHub closing keywords are scoped to
issues, so nothing closed.

**Where:** wk-pr Step 2 body composition ("PR-close keywords close issues, not
PRs").
