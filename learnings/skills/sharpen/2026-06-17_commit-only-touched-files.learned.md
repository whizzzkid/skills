---
skill: wk-sharpen
date: 2026-06-17
type: gap
severity: medium
---

Single-mode commit staged unrelated untracked files via `git add -A`.

**What happened:** Step 8 says "Commit: every dirty file in a commit." In a
single-incident sharpen, `git add -A` swept up pre-existing untracked inbox
learnings (`learnings/skills/...`, `learnings/retrospect/...`) that had nothing
to do with the edit. They had to be unstaged with `git reset -- learnings/`
before committing.

**Root cause:** "every dirty file" is correct for the files the run *touched*,
but the repo working tree routinely carries unrelated untracked batch-inbox
files. A blanket `git add -A` conflates the two.

**Suggested fix:** In Step 8, stage only the paths this run created/edited
(SKILL.md, README, references/, version bumps) by explicit path, not `git add
-A`. If `-A` is used, reset any `learnings/` or `retrospect/` paths the run did
not author before committing — those are batch-mode inbox items, distilled only
in batch mode.
