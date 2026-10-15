---
skill: wk-commit
date: 2026-10-14
type: correction
severity: medium
verified-against-source: yes
---

A lint gate piped through `tail` let a failing lint commit and push.

**What happened:** `<linter> files | tail -1 && git commit ... && git push` committed and pushed a change with a lint
offense; the `&&` gated on `tail`'s exit status (always 0), not the linter's.

**Root cause:** In a pipeline the exit status is the last stage's unless `pipefail` is set; truncating output for brevity
silently discarded the gate verdict.

**Suggested fix:** Before any commit gated on a validation command, redirect the command's output to a file, capture
`$?`, and branch on it (or `set -o pipefail`); never place a pipe between a gate and `&& git commit`. Side note: Ruby
style linters with an ASCII-comments cop flag typographic symbols such as the section sign in comments.
