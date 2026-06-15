---
skill: wk-sitrep
date: 2026-06-03
type: correction
severity: medium
---

Skip all interactive triage prompts — always add every item to the snapshot checklist.

**What happened:** During `wk-sitrep end`, the skill presented a per-group triage prompt asking the user to keep or skip each item before adding it to the snapshot. The user interrupted on the first prompt.

**Root cause:** The skill inherited the per-item triage model from the former evening sitrep flow, which was designed for a file-per-day HTML output. In the SilverBullet workspace model, the user edits the live markdown directly in the browser — triage happens in the document, not in the agent conversation.

**Suggested fix:** Remove all interactive triage prompts from `wk-sitrep end`. Write every surfaced item as a `[ ]` checkbox in the snapshot and scrubbed live.md unconditionally. The user resolves, annotates, or deletes items directly in SilverBullet. Stage 3 (Interactive resolution) becomes a compile-only pass — no `AskUserQuestion` calls.
