---
class: principle
skill: wk-pr-resolve
date: 2026-06-01
severity: high
---

- **Rule:** After any history-rewriting operation in the resolution
  session (amend, fixup + autosquash rebase, interactive rebase),
  re-run the divergence check before push; on ahead-AND-behind, recover
  by cherry-picking remote-only commits onto the rewritten tip — never
  force-push, never blindly rebase.
- **Why:** The Step 2 reconcile runs *before* the rewrite; a rewrite on
  already-pushed history produces an ahead/behind divergence the
  start-of-session check cannot catch, and rebasing rewritten history
  duplicates or drops commits.
- **Where:** Step 8 → new "Post-rewrite divergence guard" sub-section
  before "Push commits", plus a caveat in the non-fast-forward recovery.
