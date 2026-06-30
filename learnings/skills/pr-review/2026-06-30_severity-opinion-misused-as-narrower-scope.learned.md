---
skill: wk-pr-review
date: 2026-06-30
type: correction
severity: medium
---

Agent misused the "Confirmed but narrower" exception to smuggle agreement-only commentary into the review body, when the HARD RULE requires silent skip for pure Confirmed findings.

**What happened:** Phase 4 had 4 open bot threads. Three were correctness gaps the agent fully agreed with (e.g. an uncaught exception on malformed upstream JSON, an untested rescue path) — the agent added a severity/priority opinion ("same-repo producer, optional hardening, not a ship blocker") and relabeled them "Confirmed but narrower" to justify folding all three into the review body. Only the 4th thread was a genuine factual disagreement (the agent found the two "duplicate" tests actually assert different things) and qualified for surfacing. The user flagged that 3 of the 4 should have been silently skipped.

**Root cause:** The skill's dedup table allows "Confirmed but narrower/broader" as a justified-reply category, but doesn't define the bar precisely enough. The agent conflated "I have an opinion about priority" with "I have new factual evidence that narrows the bot's claim." The only worked example of a legitimate narrower-scope correction (Phase 2) is a concrete reachability check — grep shows the trigger that activates the path is absent. A severity/priority restatement is not that; it's the bot's claim repeated with an editorial gloss, which the HARD RULE explicitly calls "narrating bot validation."

**Suggested fix:** In the Phase 4 dedup table, restate "Confirmed but narrower/broader" with an explicit test: the reply must cite a fact the bot's comment didn't have (a grep result, a test run, a reachability/trigger check, an amplified downstream target) — never a standalone opinion about priority, blast radius, or whether it's "worth fixing now." Add a one-line negative example next to the table: "Not narrower: '✗ this is lower priority because it's same-repo' (opinion, no new fact) — that's Confirmed, silent skip." Add a positive contrast directly beside it so the two are read together.
