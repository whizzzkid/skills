---
class: principle
skill: wk-workstyle-shell
date: 2026-07-27
severity: medium
---

**Rule** — Never pipe a scan whose exit status is acted on into `head`/`tail`/
`sort`/`wc`. `$?` after a pipeline is the *last* command's status, and a limiter
always succeeds, so the pipeline returns 0 whether the scan matched, matched
nothing, or never read its input. Run the scan bare, or redirect to a file and read
`$?`. A count extracted through a pipe is a *value*, not a verdict — those are fine.

**Why** — A prohibited-token overfit scan run as `command grep -nE '<pattern>'
<file> | head` reported `$?` = 0 despite matching nothing; `head` succeeded, so the
pipeline succeeded. The scan printed no lines while the captured status said "hit".

Which direction it lies in is set by the guard's polarity, not by the data — and
both are reachable, so neither polarity is a safe habit:

| polarity | clean scan | real hit |
|---|---|---|
| `rc == 0` → hit | false **hit** | correct |
| `rc != 0` → clean | false **clean** | false **clean** |

**Verified against source** — reproduced directly. Bare `grep` on a no-match input
returns rc 1 and rc 0 on a match; piped through each of `head`, `tail -1`, `sort`,
and `wc -l` the no-match case returns rc 0 in all four. The redirect form
(`grep … > out`) preserves rc 1, confirming the prescribed remedy rather than
substituting a new one. A limiter that *can* fail (`| grep -q .`) is not pinned —
the defect is specific to always-succeeding limiters.

**Relation to existing rules** — this is the pipeline sibling of the already-stated
"a scan's verdict comes from its own rc, never what it printed"; the pipe is a
second way to lose the rc, alongside a hard-coded banner. The remedy already
existed in this skill but only inside the `${PIPESTATUS[…]}` zsh-portability trap,
reachable only by someone already reaching for `PIPESTATUS`. That framing is the
defect: the failing command involved no `PIPESTATUS` at all and is not a portability
bug. Hoisted to a standalone rule in the verdict family, with a pointer left at the
`PIPESTATUS` bullet so the rule stays reachable at its original site.

**Escalation — one notch, rung 1 (baseline prose) → rung 2 (`**Important:**`)** on
the pipeline-verdict rule. The rule was already installed in `wk-workflow`
("never read `$?` from a pipe: after `a | b` it is `b`'s status") — verified
installed-identical-to-worktree before escalating, and no same-session
positive-steering evidence blocks it. It was buried mid-bullet behind a lint-gate
rule, so the shape fix (its own bullet, in both skills) is the load-bearing half;
the notch only records it.

**Deferred item discharged** — `2026-07-25_pipestatus-empty-under-zsh.md` recorded
that `wk-workflow`'s gate rule prescribed `${PIPESTATUS[0]}` unqualified as the
remedy for `$?`-after-a-pipe, and deferred the correction because that run's commit
gate was blocked. Corrected here in both `wk-workflow`'s SKILL bullet and its
`2026-07-02_authoritative-gate-not-partial-signal.md` reference: the remedy is now
bare-or-redirect, and `${PIPESTATUS[0]}` is named only to forbid it.

**Where** — `wk-workstyle-shell` → Rules → new verdict-pipeline bullet after the
`grep -s`/`-q` precedence rule; `PIPESTATUS` trap bullet now points to it.
`wk-workflow` → Phase 3 verification bullets (split out, escalated to
`**Important:**`).
