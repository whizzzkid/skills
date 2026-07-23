---
skill: wk-sharpen
date: 2026-07-23
type: correction
severity: medium
---

A relocation reclaim must be budgeted by its NET byte drop (gross minus the replacement pointer), not its gross size.

**What happened:** Folding a new rule into a SKILL.md sitting 17 B under the body ceiling, I picked a peripheral prose block to relocate to references/, estimating its full size as the reclaim. After the single staged measure the body was 128 B OVER ceiling — the block's replacement (a retained heading + summary sentence + pointer link) ate roughly half its bytes, so the net reclaim was far below the gross I had budgeted against the addition.

**Root cause:** The de-bloat rule says pick reclaim targets "whose combined size exceeds the addition with ≥1.2× margin," and I read "size" as the block's gross byte count. A prose-block relocation leaves behind a non-trivial inline stub (heading + trigger sentence + reference pointer), so net reclaim ≈ gross − stub, often well under half the gross for a short block.

**Suggested fix:** In the de-bloat measure-once guidance, state that a relocation's reclaim = gross block bytes MINUS the inline stub (heading + pointer + any retained trigger sentence) it leaves behind; budget the ≥1.2× margin against that NET figure. For a small block the stub dominates — prefer relocating a LARGER narrow block (or deleting a provably-duplicated rule outright, which leaves no stub) when only a modest addition needs funding.
