---
skill: wk-sharpen
date: 2026-06-25
type: correction
severity: medium
---

When budgeting against the SKILL.md body-size ceiling, measure with the hook's exact algorithm, not an ad-hoc awk — they diverge by tens of bytes.

**What happened:** Pre-edit budgeting used `awk 'fm>=2{print}' | wc -c`, which reported a workflow body of 24566 (under the 24576 ceiling). The commit then failed `check-skill-size.sh`, whose own awk (counting `length($0)+1` per body line, starting after the closing `---`) measured 24630 — 64 bytes over. A second trim-and-recommit cycle was needed.

**Root cause:** The ad-hoc measurement and the hook's measurement differ in how they delimit the body and count line bytes (newline handling, where body counting begins). With <100 bytes of headroom the discrepancy is decisive, but the ad-hoc number read as "safe."

**Suggested fix:** In the de-bloat byte-budget step, replicate the hook's `measure()` awk (or invoke the hook's function) to get the authoritative body byte count before drafting and before committing. Treat any ad-hoc `wc -c` figure as approximate; never trust it when headroom is under ~100 bytes.
