---
class: principle
date: 2026-06-10
severity: medium
---

- **Rule:** When a finding is specific to a named CLI/tool/external app
  (curl, jq, gh, bk, docker, git, aws, …), set `SKILL_NAME` to that tool, not
  the workflow skill that surfaced it; create a `model-invocable` `wk-<tool>`
  skill once ≥2 distinct non-obvious findings would accumulate.
- **Why:** Tool quirks recur across many skills; burying them under the catch
  -all (or the review skill that caught them) hides them from future tool users.
- **Where:** Step 3 (tool-routing HARD RULE) + Step S3 classification table row.
