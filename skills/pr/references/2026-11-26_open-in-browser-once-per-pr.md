---
class: principle
skill: wk-pr
date: 2026-11-26
severity: low
---

# Open every created PR in the browser, once per PR

- **Rule:** `gh pr view "$PR_NUMBER" --web` is the next tool call after every `gh pr create`, once per PR created
  (each stacked layer and sibling included), before description sync, self-review, and the CI poll. Skip only in a
  headless session.
- **Why:** A session that opened two stacked PRs went straight from create into body sync, CI watch, ready, and
  review, and never opened either PR; the user had to ask. The rule had become a mid-paragraph clause beside heavier
  HARD RULE items, and a context-compression pass had silently dropped the `**Important:**` label the 2026-07-02
  escalation added, so the rule sat back at baseline prose.
- **Where:** `SKILL.md` → Step 3 (Post-Creation Workflow), a named bullet ahead of items 1–3.
- **Escalation (2026-11-26):** re-violation of the 2026-06-09 rule. Last recorded rung was `**Important:**` (rung 2);
  bumped one notch to `**Very important:**` (rung 3) and restored it as its own named bullet rather than a clause.
  The bullet sits before the numbered list so existing "item 2" / "Step 3.2" citations stay valid.
- **Rejected:** the suggested extra Step 5 checklist line ("every PR created this session was opened") — a second
  reinforcement in the same pass would jump the ladder; the "once per PR, every stacked layer and sibling" wording
  covers the multi-PR gap. Revisit if a later re-violation shows the Step 3 bullet alone is not enough.
