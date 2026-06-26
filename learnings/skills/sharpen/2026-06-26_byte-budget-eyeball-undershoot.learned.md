---
skill: wk-sharpen
date: 2026-06-26
type: gap
severity: low
---

Eyeballing a drafted edit's byte size under-shoots the reclaim budget; measure the addition's actual bytes before picking the reclaim quantity.

**What happened:** Folding a one-bullet rule into a near-ceiling SKILL.md (119 B headroom), I estimated the bullet's size by character count and picked no reclaim. The staged measure came back −29, then after a terser rewrite −10 — two under-shoots before a decisive content cut cleared it. The same measure-and-trim loop Step 7.5 forbids.

**Root cause:** Step 7.5 says "the new rule's byte size IS the reclaim quantity" but assumes that size is known. Eyeballing it is unreliable: a `→` is 3 UTF-8 bytes (not 1), and backticks/`incl`/punctuation push a ~115-char line well past its char count. The rule never says to MEASURE the drafted addition before sizing the reclaim.

**Suggested fix:** Add to Step 7.5's "measure exactly once": after drafting the new text but before choosing the reclaim, measure the addition's real byte delta (stage it alone, or diff the staged blob) rather than estimating from character count — multibyte glyphs (`→`, `≥`, `≤`) and markdown punctuation make eyeball counts under-shoot. Then pick a reclaim with clear margin in one pass.
