---
skill: wk-pr-merge
date: 2026-07-15
type: correction
severity: low
---

When the user asks to merge, invoke the merge skill directly rather than hand-doing a pre-step (e.g. ticking PR-body checkboxes) first.

**What happened:** Asked to merge, the agent announced it would first edit the PR body's test-plan checkboxes; the user interrupted with "run /wk-pr-merge" to skip the manual detour and enter the skill.

**Root cause:** The agent treated cosmetic PR-body cleanup as a merge prerequisite when the skill itself owns the pre-merge checklist and only blocks on unchecked items outside a deferred section.

**Suggested fix:** On a merge signal, enter the skill first; let its Step 5 action-item scan decide whether any checkbox actually blocks — do not pre-empt with manual body edits.
