---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: high
---

When a fix hardens one of N structurally-parallel blocks, enumerate ALL sibling blocks and apply the same hardening in the same commit — partial application drives multi-round review loops.

**What happened:** A spec had three parallel input-inference blocks (repo URL, PR number, commit SHA), each calling an external command and guarding its output. A reviewer bot flagged a guard gap in one block; the fix was applied to only that block. The bot then re-flagged the identical class in the next sibling block on the next round, and again on the third. Five review rounds were consumed fixing one-of-three, then two-of-three, then prose-vs-code inconsistency across the three.

**Root cause:** The Step 6 issue-class scan ("grep the full diff for every path matching the concern class") was applied within the flagged block but not across structurally-parallel sibling blocks. "Same class on different lines" was scoped too narrowly — it missed "same class in the sibling block that does the analogous thing."

**Suggested fix:** Add an N-parallel-block symmetry sweep to Step 2 mechanical sweeps: when the diff touches one block in a group of structurally-parallel blocks (multiple inference/validation/guard blocks that each capture-then-check an external call), build a symmetry matrix — for each guard/capture/assignment present in any block, verify it is present in ALL blocks unless the asymmetry is explicitly documented as intentional. Detection: identify repeated `VAR=$(cmd ...); EXIT=$?; if guard; fi; CANONICAL=$VAR` shapes; diff their guard sets. Flag any guard present in a strict subset of the parallel blocks.
