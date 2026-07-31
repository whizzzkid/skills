---
class: principle
date: 2026-07-30
severity: high
---

# Reconcile local and submitted stack membership

- **Rule:** Before stack gates, capture local PR membership, import the remote
  stack through `gh stack checkout <pr-url>`, and require set equality after
  import. Gate only the reconciled set.
- **Why:** Local tracking can omit a submitted descendant. Treating the local
  view as complete makes an active PR invisible to review, CI, and merge gates.
- **Failure:** Remote-only or local-only membership, an import error, or
  post-import divergence stops the subset merge. Re-resolve every member from
  GitHub and restart all gates; never merge the locally visible subset.
- **Verification:** Installed extension help identifies PR-URL checkout as the
  path that discovers a stack from GitHub, fetches its branches, and establishes
  local tracking.
- **Where:** `SKILL.md` → Step 1 stack detection.
- **Budget:** Body 23,799 → 24,332 bytes, below the 24 KiB ceiling.
