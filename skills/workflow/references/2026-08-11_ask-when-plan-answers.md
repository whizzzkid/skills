---
class: one-off
date: 2026-08-11
skill: wk-workflow
---

# Check plan docs before prompting for credentials

- **Scenario:** Agent asked the user how to obtain dev-realm credentials when the
  plan doc and a just-merged PR already specified them, including a local-testing
  shortcut that bypasses real credentials.
- **Symptom:** Agent treated "OIDC = sensitive" as unconditional and skipped
  re-reading the plan's local-testing guidance.
- **Fix:** Before firing AskUserQuestion for config/credential values, re-scan
  (a) the project spec/plan docs and (b) any PR URL shared in the session. Ask
  only if both are silent.
- **Why not promoted:** The continuity rules already say "Read the prompt to the end
  and enumerate every deliverable before acting." Extending to plan-doc re-reading
  is the same principle; a dedicated rule would duplicate it.
