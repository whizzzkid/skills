---
skill: wk-sharpen
date: 2026-06-26
type: correction
severity: medium
---

Pre-draft headroom estimate must use the hook's `measure()`, or the byte-budget loop thrashes.

**What happened:** While folding a learning into a near-ceiling SKILL.md, the pre-draft headroom was computed with an ad-hoc awk one-liner that under-counted body bytes by ~500. It reported comfortable headroom, so no reclaim was budgeted before drafting. The commit hook then rejected the staged blob as over-ceiling, and three measure-and-trim cycles followed to claw back bytes — exactly the search loop Step 7.5 warns against.

**Root cause:** Step 7.5 already says "use the hook's `measure()`, not `wc -c`" and "measure exactly once," but the ad-hoc awk diverged from the hook in how it counted the first body line and the closing `---`. A homegrown measure that is not a faithful replica of the hook's logic gives a false headroom reading, defeating the budget-before-drafting rule.

**Suggested fix:** Strengthen Step 7.5: the pre-draft measure must be the SAME staged-blob `git show :path | LC_ALL=C awk` replica used at commit time — never a fresh hand-written counter. Run it on the staged blob (after `git add`), not the working tree, since the hook measures the staged blob. A divergent estimate is the upstream cause of the multi-cycle trim loop, not a separate failure.
