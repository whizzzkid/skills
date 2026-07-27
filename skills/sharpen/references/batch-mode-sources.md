---
class: principle
---

# Batch mode: Source 1, Source 4, and processed-state tracking

Relocated from `SKILL.md` to hold the body under its size ceiling. Content is
unchanged — read this before draining either source.

## Source 1: Global learnings inbox

- Mirror unprocessed learnings from `$HOME/.claude/skills/learnings/` into the repo tree before distilling.
- Skip the source if the directory does not exist.
- For each `*.md` under the inbox:
  - Resolve destination as `$WK_SKILLS_HOME/learnings/skills/<relative-path>`.
  - Skip if the destination already exists.
  - Copy the file, then delete the inbox original.
- Fall through to Source 2.

## Source 4: Session retrospects

- Scan `$WK_SKILLS_HOME/learnings/retrospect` for unprocessed retrospect files.
- Read each "What could've been better" and any "What worked" bullet that asserts a reusable practice.
- Match each lesson to a skill by name/tool/phase.
- Materialize each matched lesson as a learning via `wk-learn`.
- Distill it through the Source 2 path and rename it to `.learned.md`.
- After every lesson in the file is distilled, rename the retrospect file itself.
- A lesson whose slug already exists is already distilled.

## Why a "drained" verdict needs a structurally-capable control

- A traversal that skips a class of node — `find -type f` never descends a symlinked
  directory — returns zero for content rooted under those nodes. The zero is dead, yet
  indistinguishable from a real drain.
- So plant an in-place canary in the scanned tree, re-run the *identical* invocation form,
  and corroborate with a primitive lacking that blind spot (`ls -laR`, `find -L`).

## Tracking processed sources

- **Learnings (Source 1 & 2):** processed state is the `.learned.md` rename.
- **Retrospects (Source 4):** same as learnings.
- **Memories (Source 3):** tracked by a gitignored marker at `$WK_SKILLS_HOME/.distilled-memories`.
- Reprocess on change. `--scan --force` ignores every marker and rename-state, re-distilling all.
