---
class: principle
skill: wk-workstyle
date: 2026-11-20
---

# Formatter-vs-convention conflicts: the convention's formatter is the oracle

- **Rule:** When the configured formatter's output disagrees with the style the repo's code follows, run the
  convention's own formatter on scratch copies to get the expected output. Never run it on the tree, never guess the
  output by hand, and surface the conflict to the user before reformatting.
- **Why:** Hand-predicting another formatter's output is unreliable. Running the real tool on copies gives the exact
  expected bytes with no working-tree churn. "Project config wins" still governs findings; the oracle only settles
  what the convention looks like.
- **Where:** `SKILL.md` → Step 0. Source: session-6 retrospect, "What worked".
