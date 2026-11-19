---
skill: wk-pr-merge
date: 2026-11-19
type: gap
severity: low
verified-against-source: n/a
---

Auto-mode permission layer can refuse `gh pr merge` even when a human approved and CI is green.

**What happened:** All gates passed (human approval, green required checks, CLEAN merge state), but the merge call was
denied as "Merge Without Review", costing a round trip to the user.

**Root cause:** The skill only warns about permission refusals for bot-only approvals; the auto-mode classifier can
also refuse agent-initiated merges with a human approval present.

**Suggested fix:** In Step 6, when running in auto mode with no permission rule allowing `gh pr merge`, tell the user
before the call that they may need to click merge themselves (and offer the browser link) or add a permission rule.
