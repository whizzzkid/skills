---
class: principle
---

# Cite the required-status list before claiming a check cannot block

- **Rule:** Before any claim that a check, status, or red build cannot block a merge, read the branch's
  required statuses from both sources — `rules/branches/{branch}` (rulesets) and classic
  `branches/{branch}/protection/required_status_checks` (404 = none) — and cite the contexts.
- **Why:** The claim was inferred from pipeline config (no notify or status step), but the CI provider posted its
  own build status, and that context was required on the default branch. The false claim shipped in a PR body and a
  code comment before a verifier caught it. Required statuses live in branch rules; the pipeline cannot show them.
- **Where:** [`wk-gh`](../README.md) → CI Status and Merge Readiness.
