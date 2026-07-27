---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: high
verified-against-source: yes
---

A landing-location check read the *installed* skill copy and reported two landed folds as missing.

**What happened:** A run needed to confirm where two folds had landed. The skill's
`SKILL.md` carried one prominent rule naming a specific copy to read — "Escalate only
against *installed* text" — and the run applied it to the landing question. Under a
three-way divergence (installed / HEAD / worktree all different byte counts, the normal
state whenever a commit gate is blocked and folds sit uncommitted), the installed copy did
not yet contain either fold, so both were reported missing even though both were present in
the worktree.

**Root cause:** Two different questions, only one of which the skill answers about *which
copy to read*.

- The escalation rule is correctly scoped to the escalation judgement: an unshipped rule
  cannot have steered the failing run, so escalation evidence must come from installed text.
- The landing-location check is the opposite question — "did my edit land?" — and its only
  correct target is the worktree, where an uncommitted fold lives by definition.
- `SKILL.md` orders the landing confirmation ("confirm the distilled principle landed") and
  the final re-read ("re-read the final file end-to-end") without naming a copy for either,
  while the sole copy-naming rule in the file points at `installed`. The nearest available
  rule therefore gets applied to a question it does not govern.

**Suggested fix:** State the complementary half of the rule where the landing check is
ordered — a landing/verification read targets the **worktree**, never the installed copy —
and bound the installed-text rule explicitly to escalation evidence so the two cannot be
confused. Under divergence the two reads answer different questions and must not be
substituted for one another.
