---
skill: wk-pr
date: 2026-07-01
type: gap
severity: medium
---

GitHub's `Closes #N` keyword auto-closes issues, not pull requests.

**What happened:** A combined dependency PR used `Closes #N` to auto-close the individual superseded dependabot PRs on merge; the annotation does not close PRs, only issues.

**Root cause:** GitHub closing keywords are scoped to issues. A `#N` reference to a PR renders as a link but triggers no auto-close on merge.

**Suggested fix:** When asked to "auto-close PRs on merge", state that `Closes` won't do it; the reliable mechanisms are (a) Dependabot auto-closing its own superseded PRs on its next run once versions land on the base branch, or (b) posting `@dependabot close` comments / a close-on-merge Action. Keep the `Closes` annotation only as documentation of supersession.
