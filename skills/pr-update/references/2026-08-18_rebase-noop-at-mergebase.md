---
class: principle
source: learnings/skills/git/2026-08-18_rebase-onto-mergebase-noop.md
date: 2026-08-18
severity: medium
---

## A rebase onto the existing merge-base is a silent no-op

Re-signing a commit that sat unsigned partway through a branch's history, the caller
ran a rebase from that commit's merge-base expecting every later commit to be
recreated under the local signing key. The command reported success. Every SHA in the
range was unchanged and the unsigned commit stayed unsigned. `--rebase-merges` did not
change this; `--force-rebase` did, producing new SHAs and a valid signature.

**Mechanism:** git treats a rebase target already equal to the merge-base as
"already up to date" and takes a fast-path no-op, because the resulting topology would
be identical. That reasoning is sound for the usual goal of moving a branch, and wrong
whenever the caller wants commit objects *recreated* for a side effect — re-signing,
re-authoring, refreshing committer metadata — where the point is new objects, not a
different tree.

**Guard:** pass `--force-rebase` when the goal is recreation rather than relocation,
and treat a changed HEAD SHA as the only proof the rewrite ran. A clean exit, an
absence of conflicts, and an ahead/behind count are all consistent with nothing having
happened.

**Filed against a skill with no directory.** The report named a `wk-git` skill that
does not exist on disk. Routed to the skill owning rebase invocation rather than the
one owning signing: the defect is rebase fast-path semantics, and the signing skill
already carries the rule that a rewrite must re-sign what it touches — what it lacked
was any reason to doubt the rewrite occurred.

**Landed in:** `SKILL.md` Stage 3b (rebase strategy).
