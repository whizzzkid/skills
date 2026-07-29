---
class: principle
---

**Rule**

After editing any concept in a spec/doc, grep the whole document for its core
terms and review every hit for consistent tense, qualifier, and implementation
status before committing.

**Why**

A diff-focused edit updates the primary narrative section but leaves a
risk-table row or summary stating the old default/qualifier (e.g. present-tense
assertion vs. "(planned vX.Y)"). Cross-section drift doesn't surface in a diff
review and is a top bot-review flag.

**Escalation**

Re-violated once (2026-07-28): a verdict reversal was swept by the retracted wording,
so two spots the old verdict had justified survived the correction pass. Escalated
rung 1 → 2 (`**Important:**`) and sharpened to sweep by the subject's *identifier*
rather than the edited phrasing — the shape fix is what makes the rule reachable; the
notch only records the repeat.

**Where**

`skills/docs/SKILL.md` → Step 4 spec quality gate.
