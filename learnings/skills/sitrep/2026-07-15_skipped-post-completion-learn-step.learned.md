---
skill: wk-sitrep
date: 2026-07-15
type: gap
severity: medium
---

Ran `start` end-to-end (gather, compile, write, verify, commit/push) and then just stopped — never invoked the skill's own Post-Completion step (`wk-learn sitrep`) until the user pointed out it was missing.

**What happened:** The skill file ends with an explicit "## Post-Completion" section instructing the run to invoke `wk-learn` with the skill's short name as the final action. That instruction sits at the bottom of the file, after Stage 6 (commit and push), with no corresponding stage number and no callback from Stage 6 telling the run to go read it. After announcing "Live page ready" and finishing the commit, the run treated the task as complete and moved on — the Post-Completion section was never re-visited.

**Root cause:** Post-Completion is structurally an appendix, not a numbered stage in the `start` or `end` flow. A stage list that already ends at "Stage 6: Commit and push" reads as the full lifecycle; nothing in Stage 6 says "then proceed to Post-Completion," so it's easy to treat commit+push as the finish line and never scroll to the trailing section. This is the same class of failure as skipping a verify step that's described in prose instead of gated as a hard stage — the fix pattern that already worked for the render-verification gap should apply here too.

**Suggested fix:** Fold the `wk-learn` invocation into Stage 6 itself (rename it "Stage 6: Commit, push, and capture learnings" or add a "Stage 7" explicitly numbered and referenced from Stage 6's closing line) so it's part of the same checklist the run is already executing, rather than a detached section below the fold that only gets read if someone scrolls past the Quick Reference table.
