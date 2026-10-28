---
class: principle
---

# Fork CI before the upstream PR

**Rule** — when the push remote is a fork of the PR target, get a green CI run inside the fork before opening the
upstream PR. Detect with `gh repo view <push-remote> --json isFork,parent`; enable the fork's Actions if disabled,
sync the fork's base branch, open a CI-only PR inside the fork, wait for green on its HEAD, then open the upstream PR
and close the fork PR. No job ran in the fork → say so in the upstream body; never claim CI passed.

**Why** — GitHub gates workflow runs on fork PRs behind maintainer approval for many contributors; the run reports
`action_required` and never executes. Opening the upstream PR first hands the maintainer a change with no CI signal,
so defects CI would have caught land in their review instead. A fork's Actions are often disabled by default and its
base branch can trail upstream, so both must be fixed before the fork run is meaningful.

**Where** — `SKILL.md` → Step 2 (Create Draft PR), HARD RULE on fork push remotes. Complements the upstream OSS
pre-flight in `wk-workflow`.
