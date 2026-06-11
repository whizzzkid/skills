---
class: principle
date: 2026-06-10
skill: wk-pr-resolve
---

- **Rule:** When a finding's anchor file differs from the file that needs
  the change, lead the Suggested fix with "Fix is in `{file-to-change}` —
  `{anchor-file}` is already correct and needs no change."
- **Why:** A merged finding spanning two files leaves the user unsure
  whether both need editing (e.g., a bot comment on a source file whose
  README is already correct).
- **Where:** Step 4 Suggestion format.
