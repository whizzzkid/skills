---
class: principle
date: 2026-06-15
---

# De-bloat is mandatory every run, under a hard 24 KiB ceiling

**Rule:** Run the de-bloat/concision pass on every sharpening, not only when a
learning prompts it. Enforce a hard size ceiling per `SKILL.md` (target well
under 24576 bytes). When a skill exceeds the ceiling, refactor, split into
`references/`/sub-skills, or scope it down before finishing — coverage-preserving,
never by dropping a HARD RULE, error code, or failure-mode.

**Why:** Each pass optimized only for capturing the new rule, treating sharpen as
additive; bloat is the cumulative default of append-only edits. Several SKILL.md
files grew past 1000–1800 lines and required a weekend of out-of-band cleanup. A
size ceiling plus a mandatory de-bloat step makes total document health a gate,
not an afterthought.

**Where:** Step 7.5 De-bloat Pass — two HARD RULEs (de-bloat every run; 24 KiB
ceiling). Backstopped by `.githooks/check-skill-size.sh`
(`SKILL_SIZE_MAX_BYTES`, default 24576).
