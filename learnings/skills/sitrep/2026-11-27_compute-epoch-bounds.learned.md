---
skill: wk-sitrep
date: 2026-11-27
type: correction
severity: low
verified-against-source: yes
---

Hand-typed Unix epoch window bounds in an agent brief were an hour off; the agent caught it only by cross-checking.

**What happened:** The orchestrator wrote literal epoch seconds for the closed-day window into the chat-search brief. Converting them back showed the lower bound landed at 01:00 local on the next day, not 00:00 on the closed day. The agent noticed, corrected, and reported it.

**Root cause:** Epoch bounds were composed by hand instead of computed; a timezone/DST-style offset slipped in.

**Suggested fix:** Compute every epoch bound in the shell from the ISO date and zone (`date -j -f` with `TZ` set) and paste the printed values into briefs; tell agents to verify one bound against a known message timestamp.
