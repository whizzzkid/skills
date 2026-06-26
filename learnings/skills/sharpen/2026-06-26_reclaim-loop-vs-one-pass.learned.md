---
skill: wk-sharpen
date: 2026-06-26
type: correction
severity: low
---

At a near-ceiling SKILL.md, I ran ~5 trim-then-remeasure iterations instead of sizing the reclaim in one pass.

**What happened:** Body was 12 B under the size ceiling. I drafted the new rule, measured, found it over, trimmed one spot, remeasured, still over, trimmed another — five candidate measurements before landing under. The skill's "Budget the reclaim before drafting" HARD RULE already prescribes: sum the new bytes, pick reclaim targets totaling ≥ that sum, apply in ONE pass before remeasuring.

**Root cause:** The rule is stated but did not steer execution — a re-violation. The pull toward "tweak and recheck" is strong when each measurement is cheap; the rule needs to read as a hard stop against incremental remeasuring, not advice.

**Suggested fix:** Escalate the existing "trim-then-remeasure turns one edit into a search loop" line one notch, or add a mechanical pre-draft checklist: (1) sum new-rule bytes, (2) name a structural reclaim ≥ that sum, (3) apply both edits, (4) measure exactly once. Treat a second measurement-and-trim cycle as the violation signal.
