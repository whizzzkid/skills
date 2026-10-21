---
class: principle
date: 2026-10-21
severity: low
---

# Run the POST-permission preflight in every mode

- **Rule:** Run Step 0.5 before Step 1 on every invocation — auto mode included. The preflight is a
  precondition, not an optional warning.
- **Why:** The auto-mode classifier denies the pending-review POST at Step 4, after the payload is built. A skipped
  preflight moves the denial to the most expensive point in the flow. The incident was a re-violation of the existing
  baseline-prose Step 0.5 rule, so it was escalated one rung to `**Important:**` and given an explicit "every mode"
  clause.
- **Where:** `SKILL.md` → Step 0.5.

## Rejected suggestion

- **Suggested:** in auto mode with no matching allow rule, write the payload and hand the user the one-liner without
  attempting the POST.
- **Rejected because:** a missing allow rule does not prove a denial. The classifier still decides the actual POST,
  and the installed design ("this only warns early") lets an allowed POST go through. Skipping the attempt would
  also undercut the post-immediately rule in Step 4. The existing blocked-POST recovery (payload already on disk via
  Write → hand over the one-liner) covers a denial at no extra cost.
