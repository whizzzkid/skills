---
skill: wk-pr-review
date: 2026-05-11
type: correction
severity: medium
---

Review body should not re-narrate confirmed bot thread findings as "Re: Copilot thread on X — confirmed" anchors.

**What happened:** Phase 5 correctly classified all bot findings (confirmed/refuted) and followed the skill's option-(a) guidance to fold confirmed bot thread responses into the review body with anchor references. This produced several "Re: Copilot thread on gdev-wish/src/lib.rs:324 — confirmed" lines in the review summary.

**Root cause:** The skill's option-(a) framing ("fold into review body with an anchor reference") is intended to deliver the validation verdict to the author — but when the bot finding is simply *confirmed* with no new evidence, that verdict is noise. The author already sees the bot thread; a body line saying "yes the bot was right" adds nothing actionable. The only case where a body anchor adds value is when the agent has *new evidence* the bot missed (Inconclusive + agent flagged it, or Confirmed + playground surfaced something additional).

**Suggested fix:** In Phase 5 "Deduplicate against existing comments", tighten the option-(a) rule: only fold a bot-thread anchor into the review body when the agent's validation produced new evidence beyond confirming the bot's exact claim. Pure "Confirmed, no new evidence" cases should be silently skipped — the bot thread already stands. Reserve body anchors for Refuted (counter-evidence) and Inconclusive-with-agent-flag cases.
