---
skill: wk-pr-resolve
date: 2026-05-15
type: gap
severity: low
---

Read spec doc before presenting description-check consultation

**What happened:** A bot "description-check" finding claimed a behavioral design decision was undocumented in the PR body. The consultation was presented without first verifying whether the behavior was already documented in the repo's spec docs or obvious from reading the code. The user interrupted to clarify the design intent rather than choose (a)/(d).

**Root cause:** Step 4 suggestion generation reads the flagged file and the bot's comment, but doesn't check referenced spec docs or verify whether the claimed-missing documentation already exists in the repo before surfacing the consultation.

**Suggested fix:** For "description-check" bot findings, add a pre-consultation step: grep the diff for spec doc paths, read those docs, and verify whether the bot's "missing" claim is accurate. If the design is already documented in the spec, present the consultation with that context ("spec covers it at docs/specs/X.md") so the user can make an informed dismiss decision rather than needing to clarify what the agent could have found itself.
