---
class: principle
---

**Rule** — Before base detection (Stage 1), validate the current branch has an open PR.
A worktree's checked-out branch may be an abandoned stacked child whose PR is closed,
while the actual target is the parent's open DIRTY PR.

**Why** — `gh pr view` defaults to the current branch; if that branch's PR is closed,
base detection returns the closed PR's base, and the entire update targets the wrong PR.

**Where** — `SKILL.md` → Stage 1 → PR-state validation.
