---
class: principle
source: learnings/skills/pr-update/2026-11-23_base-moves-during-ci.learned.md
date: 2026-11-23
severity: low
---

## Re-check merge state after CI goes terminal

- **Rule:** Watch CI on the integrated head in the background. Once it is terminal and before any merge-ready report,
  re-query the PR's `state` and `mergeStateStatus`. `MERGED` → hand off to `wk-pr-merge`'s post-merge steps and never
  integrate again; `DIRTY`/`BEHIND` → loop from Stage 1 once more.
- **Why:** On a busy base, CI went green on the integrated head while the merge state was already DIRTY again because
  base had moved. One cycle later the new base commit was the PR's own squash: the user had merged it mid-watch. The
  skill ended at push + sync and never looked again.
- **Where:** `SKILL.md` Stage 6. The same lesson appeared in the 2026-11-23 session retro.
