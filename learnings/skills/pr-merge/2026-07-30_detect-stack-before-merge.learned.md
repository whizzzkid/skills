---
skill: wk-pr-merge
date: 2026-07-30
type: gap
severity: high
verified-against-source: yes
---

Detect stack membership before selecting the single-pull-request merge path.

**What happened:** Several pull requests were linked as one GitHub stack, but the merge workflow
would have handled them individually. The installed stack extension was old enough to omit the
merge command; after upgrading the GitHub-owned extension, `gh stack merge` merged every layer in
one all-or-nothing operation and all members reported the same merge commit.

**Root cause:** The merge skill starts from one pull request and never probes `gh stack view`, so it
cannot choose GitHub's atomic stack merge. It also assumes that an installed stack extension has
the current command set instead of checking `gh stack --version` and `gh stack merge --help`.

**Suggested fix:** Before single-pull-request gates, probe `gh stack view --json`. When the target is
in a stack, enumerate the included pull requests from stack metadata and run CI, review, thread,
action-item, and waiver gates for each. Read the repository ruleset's allowed merge methods, verify
`gh stack merge --help`, and use
`gh stack merge <stack-number> --yes --merge-method <allowed-method>`. If the installed
GitHub-owned extension lacks the command, surface and perform an approved extension upgrade before
falling back to sequential merges. Afterward, verify every member is `MERGED` and that the target
branch points to the reported stack merge commit.
