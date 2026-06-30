---
skill: wk-sharpen
date: 2026-06-30
type: correction
severity: low
---

At single-digit byte headroom, the de-bloat reclaim took three measure-trim cycles instead of one decisive cut.

**What happened:** Folding a one-bullet rule into a SKILL.md body with only 26 bytes of headroom, I drafted, measured (over by 20), trimmed, measured (exactly at ceiling), trimmed again — and one of the trims fat-fingered bytes UP instead of down, needing a fourth fix. The Step 7.5 "measure exactly once / a second cycle is the re-violation signal" rule fired in my reasoning but I still iterated.

**Root cause:** I edited prose incrementally and re-measured after each nibble rather than budgeting the full reclaim up front. The existing rule already prohibits this; the violation was discipline, not missing coverage.

**Suggested fix:** Existing coverage at Step 7.5 ("measure exactly once", "second measure-and-trim cycle is the re-violation signal", "budget >=2 reclaims up front"). Candidate for escalation if this pattern recurs — the rule is being read past under time pressure. Consider a pre-draft gate: when headroom < 2x the drafted rule, REQUIRE staging the draft and naming reclaim targets before the first edit lands.
