---
skill: wk-sharpen
date: 2026-07-20
type: pattern
severity: low
---

Adding a HARD RULE to an at-ceiling SKILL.md triggered four reactive measure-and-trim cycles — the exact "re-violation signal" the de-bloat gate names.

**What happened:** Folding a high-severity rule into a skill whose body already sat exactly at the size ceiling. I drafted the rule first, then discovered the over-ceiling state at the first measure, and reclaimed in successive nibbles (over by 372 → 140 → 36 → 7 bytes across four passes) before landing under.

**Root cause:** Skipped the gate's "budget the reclaim before drafting when headroom is tight" step. I did not measure the staged body BEFORE writing the addition, so I never knew the skill was at the ceiling until after the edit, forcing a reactive trim loop instead of one planned decisive cut.

**Suggested fix:** The de-bloat gate already prescribes measuring first and budgeting ≥2 reclaims when headroom is under ~2× the edit — but it fires as a size check, not as a pre-draft trigger. Make the "measure the staged SKILL.md body BEFORE drafting any addition" step explicit and unconditional whenever the fold ADDS content, not only when headroom is already known to be tight — the at-ceiling state is precisely what you cannot see without measuring first.
