---
skill: wk-sharpen
date: 2026-06-25
type: pattern
severity: low
---

When a SKILL.md body is already near the size ceiling, budget the byte cost of the new rule before drafting it — not after.

**What happened:** The target body was ~58 bytes under the 24576-byte ceiling. The new rule plus a small reclaim still overshot, forcing three measure-edit cycles to land under the limit.

**Root cause:** The de-bloat pass measured size only after drafting the functional edit, so the first reclaim was sized by guess and undershot the addition.

**Suggested fix:** When `ceiling - current_body < ~2x` the drafted edit size, identify the reclaim target (merge-overlap or relocate-to-references) and estimate its savings *before* writing the new rule, so the net change is non-positive on the first pass. Measure once to confirm, not to discover.
