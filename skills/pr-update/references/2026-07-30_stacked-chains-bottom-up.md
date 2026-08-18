---
class: principle
source: learnings/skills/pr-update/2026-07-30_resolve-stacked-prs-bottom-up.md
date: 2026-07-30
severity: high
---

## Stacked chains resolve bottom-up, and a rewrite is not proof of change

Review fixes landed on the first PR of a stack while later PRs were already open. Each
descendant needed the resolved parent tip integrated before its own findings or CI meant
anything. Stack tooling then linearized the descendant histories mid-flight: the new
remote tips carried different commit IDs over identical trees, so re-solving the
conflicts would have redone work that had already landed.

**Mechanism:** a stacked branch is simultaneously an independent review unit and the
base of another review unit, so updating a parent invalidates every descendant's diff,
conflict context, and CI basis. Separately, stack tooling may rewrite descendant history
after a push without changing the resulting tree — commit identity and content change
independently, and only one of them matters for whether work must be redone.

**Two rules, and the second is the load-bearing one.** Ordering alone tells you to
integrate the parent into the child; it gives no way to tell whether a rewritten stack
actually changed anything. Without the tree comparison, a history-only rewrite is
indistinguishable from a real content change, and the safe-looking response — redo the
integration — silently duplicates resolved conflicts.

- Rediscover the live stack after each parent update; cached topology is stale the
  moment a parent moves.
- Parent first: resolve, verify, integrate that exact tip into the direct child, audit
  every auto-merged overlapping file for intent from both sides, run the child's full
  gate, then move up. Replies and thread resolution wait on the confirmed remote head.
- `git diff --quiet <verified-tip> <live-tip>` discriminates: rc 0 is history-only and
  needs nothing redone; non-zero is a real content change to re-integrate and revalidate.

**Marker provenance.** This learning was found carrying a `.learned.md` name with no
corresponding fold anywhere in `skills/`. Subject-match against the target skill found
neither rule installed; the only `diff --quiet` occurrence was an unrelated lockfile
check. The name was a premature claim about state, not evidence of one.

**Not duplicated here:** retargeting a child onto the parent's base before merging the
parent, which the merge skill already owns.

**Landed in:** `SKILL.md` Stage 1 → "Stacked chains — work bottom-up".
