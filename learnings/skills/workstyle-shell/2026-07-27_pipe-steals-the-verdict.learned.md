---
skill: wk-workstyle-shell
date: 2026-07-27
type: correction
severity: medium
verified-against-source: yes
---

A verdict-bearing scan piped into `head`/`tail`/`sort` reports the limiter's status, not its own.

**What happened:** Running a prohibited-token overfit scan as
`command grep -nE '<pattern>' <file> | head` and then reading `$?` returned **0** even though
`grep` had matched nothing. `head` succeeded, so the pipeline succeeded. The scan printed no
lines, and the captured status said "hit" — the opposite of the truth. Had the branch been
written the other way (`rc != 0` → clean), the same pipe would have produced a false **clean**
on a real hit, which is the direction that ships a defect. Re-running the identical scan without
the pipe returned rc **1** (clean).

**Root cause:** `$?` after a pipeline is the exit status of the **last** command in it, not the
one whose verdict is wanted. A limiter or pager placed after a scan for readability silently
becomes the status source. This is the pipeline form of the already-known rule that a scan's
verdict comes from its own rc and never from what it printed — the pipe is a second way to lose
that rc, alongside a hard-coded banner.

**Suggested fix:** For any scan whose exit status is acted on, forbid the trailing
`| head` / `| tail` / `| sort` / `| wc` entirely — run it bare and capture rc immediately. When
output really must be limited, capture the status explicitly (`${PIPESTATUS[0]}` in bash, after
the pipeline and before any other command) and never `$?`. Note in the same breath that
`PIPESTATUS` is a bash array and is not portable to plain `sh`; zsh spells it `pipestatus` with
1-based indexing. Pair the rule with the existing "a banner is not a verdict" guidance so both
ways of losing a scan's rc are stated together.
