---
skill: wk-pr-resolve
date: 2026-06-30
type: gap
severity: medium
---

PR description was not audited for drift during a wk-pr-resolve run that only resolved self-review threads.

**What happened:** The run identified and resolved self-review threads, then stopped. It never fetched the PR description to check for staleness, missing sections, or claim drift — despite the skill requiring agent-observed drift to be treated as first-class feedback and a mandatory description sync after push.

**Root cause:** The skill's Step 3 "agent-observed drift" instruction and Step 8 "sync PR description immediately after push" hard rule are easy to skip when the visible work (resolving threads) feels complete. No explicit checklist item forces a description read before the run concludes.

**Suggested fix:** Add an explicit Step 3 sub-step: read the current PR description and diff it against the actual branch state; inject any staleness or missing-section findings as `surface: agent_observation` before triaging reviewer comments. This ensures the description is always audited, not only when a reviewer flags it.
