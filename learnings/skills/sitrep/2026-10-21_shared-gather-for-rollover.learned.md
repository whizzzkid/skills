---
skill: wk-sitrep
date: 2026-10-21
type: gap
severity: low
verified-against-source: n/a
---

Rollover close and today's start gather the same evidence window; one agent fleet can serve both.

**What happened:** `start` found an unclosed prior day, which implies a full `end` flow (7 agents) before `start`'s own
5 agents. Both need the prior workday's evidence, so one fleet of 6 was launched with a three-part return: open now,
prior-day evidence, carry-over status. It fed the snapshot, the brag log, and today's page without a second round.

**Root cause:** The skill describes the two gathers as separate launches and never says the prior-day evidence can be
shared when the rollover day equals the previous workday.

**Suggested fix:** In the missed-end rollover reference, allow a single shared gather (A open now / B prior-day
evidence / C carry-over status) when the closed day is the previous workday; require the window bounds in the brief.
Also note that a carry-over's completion timestamp should be re-read from the ticket system, since a prior page can
record it a day off.
