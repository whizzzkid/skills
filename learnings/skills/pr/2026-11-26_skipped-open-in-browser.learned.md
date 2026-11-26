---
skill: wk-pr
date: 2026-11-26
type: correction
severity: low
verified-against-source: n/a
---

The "open the PR in the browser" step was skipped for every PR created in a session; the user had to ask.

**What happened:** Two PRs (one stacked on the other) were created with `gh pr create`. The agent went straight into
body sync, CI watch, ready, and review, and never ran `gh pr view --web`, even though Step 3 requires it in the same
response as the create.

**Root cause:** The browser-open instruction is a mid-paragraph clause in Step 3, next to heavier HARD RULE items
(self-review, CI poll). Under a multi-PR flow, attention went to the hard rules and the clause got dropped.

**Suggested fix:** Make the open a fixed, named action: "`gh pr create` → `gh pr view <n> --web` is the next tool call,
once per PR created." Also add it to the Step 5 checklist ("every PR created this session was opened in the browser"),
so a stacked or multi-PR session can't skip it for later PRs.
