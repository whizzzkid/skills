---
class: principle
---

# Superseded & closed PRs

**Rule** — `Closes`/`Fixes`/`Resolves #N` auto-close only **issues** on merge,
never a PR (a `#N` PR reference just links). To close a superseded PR, use a
close-on-merge Action or a close comment; keep `Closes #N` as supersession
documentation. A PR auto-closed by a squash-merged + deleted base cannot be
reopened or retargeted (`gh pr reopen` and `gh pr edit --base` both fail) —
create a fresh superseding PR (rebase mechanics: `wk-pr-takeover` Step 3).

**Why** — relying on `Closes #N` to close a superseded PR silently leaves it
open; assuming a squash-merged + deleted-base PR can be revived wastes a reopen
attempt and blocks the follow-up.

**Where** — Step 2, PR body composition, whenever a PR supersedes or references
another PR for closure.
