---
class: principle
---

# The mark-ready commitment covers every draft the session opened

**Rule** — Never end a turn with **any** draft PR whose work is done. The commitment
is per-PR across every draft the session opened, not only the last one touched.

**Why** — The rule was installed 2026-07-28 and read naturally as being about *the*
draft in hand: "never end a turn with a draft PR whose work is done". A session that
opens several PRs satisfies that reading by readying the one it just pushed to, and
leaves the siblings as drafts without ever contradicting the text. The reported
failure was exactly that — all PRs left in draft. Widening the determiner and naming
the enumeration closes the reading at a two-byte cost, which is why this beat a
louder label.

**Where** — `skills/pr/SKILL.md` → Step 5 Mark Ready: the HARD RULE lead and its
closing line.

## Escalation record

- Re-violation of text live since 2026-07-28 → the notch is carried by the
  restructure rather than a priority label: the rule already leads with **HARD RULE**,
  so there was no label headroom, and the defect was scope, not volume.
- No positive-steering evidence blocked it — that session's "What worked" bullets
  covered a subtractive fix, a schema backfill, and ADR discipline.

## Byte note

`wk-pr` had 133 B of headroom, so the fold was constrained to 60 B and deliberately
shaped as a determiner change plus one clause. A fuller version naming an
enumeration command was drafted and cut for budget; the surviving text still forbids
the failing behavior, which is the part that had to land.

## Sibling lessons from the same source

- *Never claim CI green without checking the current HEAD SHA* — covered: the
  rollup-terminal rule in this skill, the stale-`headRefOid` rule in the GitHub
  skill, and the completion checklist now binding CI-green to the shipped head.
- *Poll for bot review comments after every push* — covered by the resolve skill's
  post-push finalization (refresh bot threads against HEAD) and its re-run of the
  fetch step against post-push HEAD.
- *Execute a user-named tool immediately or report the blocker* — covered by the
  mid-session-asks-are-deliverables rule. **No notch:** that rule landed 25 minutes
  before this retrospect was written, so the failing run had almost certainly already
  begun; treated as `already-covered (unshipped)` rather than escalating on a
  timing technicality.
- *Rebase children after a parent merges* — folded into the PR-update skill, which
  owns the merged-parent `--onto` replay, rather than the merge skill whose body had
  262 B left. Retargeting a child's base is not rebasing it.
