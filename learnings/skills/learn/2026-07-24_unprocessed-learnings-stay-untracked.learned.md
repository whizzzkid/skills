---
skill: wk-learn
date: 2026-07-24
type: gap
severity: low
---

A freshly written learning cannot be committed: the filename hook only accepts
`.learned.md`, so unprocessed learnings must stay untracked until distilled.

**What happened:** After writing a new learning as `<YYYY-MM-DD>_<slug>.md` (the
shape this skill mandates), `git add` + the pre-commit filename hook rejected it:
the hook requires `<YYYY-MM-DD>_<kebab>.learned.md` and explicitly reports "a
plain `.md` is unprocessed". The correct action was to unstage and leave the file
untracked for the next distillation run to rename and commit.

**Root cause:** This skill tells the agent to "confirm the path matches
`<YYYY-MM-DD>_<slug>.md` ... before writing or `git add`", which reads as an
instruction to stage the new file. It does not state that the repo deliberately
keeps undistilled learnings out of history — the `.learned.md` rename performed
at distillation time is what makes a learning committable.

**Suggested fix:** State plainly in Step 3/Step 4 that a new learning is left
**untracked** — never `git add`ed — and that the distillation pass is what renames
it to `.learned.md` and commits it. Drop `git add` from the suffix-validation
sentence so the guidance stops implying the file should be staged. Add to Step 4's
signal line that an untracked learning in the working tree is the expected state,
so a later "clean tree" check does not treat it as leftover debris to remove.
