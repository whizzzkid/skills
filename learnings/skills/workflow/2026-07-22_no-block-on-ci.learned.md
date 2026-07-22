---
skill: wk-workflow
date: 2026-07-22
type: gap
severity: medium
---

Never hard-block on a CI poll when independent tasks remain ahead in the plan.

**What happened:** After pushing a stacked PR and staging its self-review, the
agent launched a foreground/background CI poll and idled on it — even though the
next planned task (the following stacked PR) had no data dependency on the
in-flight PR's CI result. The user interrupted to say don't stall on CI, do the
other work while CI runs.

**Root cause:** The PR lifecycle (`wk-pr`) is written as a linear
push → self-review → poll CI → ready sequence, so the agent treats the CI poll
as a barrier and waits. But the poll already runs in the background and re-invokes
the agent on completion; blocking on it wastes wall-clock when other plan items
could progress in parallel.

**Suggested fix:** After launching a background CI poll, check the plan for the
next task with no dependency on this PR's CI/green state. If one exists, proceed
to it immediately and let the poll notify; return to the CI-green →
resolve-threads → `gh pr ready` tail when the notification fires. Only hard-wait
on CI when nothing else can progress — the last PR in a stack, or a step that
genuinely needs green CI (e.g. auto-merge, or a base a later PR must build on
only once merged). Interleaving the tail of PR N with the body of PR N+1 is the
default, not the exception.
