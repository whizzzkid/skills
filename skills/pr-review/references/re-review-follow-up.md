# Re-review follow-up

Detect prior comments by the current user (`gh api user --jq '.login'`) and close the loop before new issues:

- **Fix applied** → validate against current code, draft acknowledgment.
- **Wrong fix** → follow-up grounded in current code.
- **Partial fix** → reply on the original thread naming what is still open (see "Verify each fixed reply").
- **Deferred with a tracking link** → plus-one for low; nudge for concerns. **No tracking link** → still open; treat
  as unanswered and nudge.
- **Pushback** → answer with evidence or restate.
- **No response / resolved** → skip.

A modified file proves an attempt, not a fix. Dedup against prior threads.

## Verify each fixed reply

Run one mechanical check per finding at the PR head blob (`git show <PR_HEAD>:<file>`), never the reply text:

- **Pattern-level, not quoted-line:** grep the finding's pattern across the whole changed file and its siblings
  (same directory, same artifact kind). A fix often lands only on the quoted instance; other instances keep the
  finding open.
- **Fix-induced contradictions:** diff the fix delta for rules, lists, or enums it newly tightens or extends, then grep
  the dependent artifacts (cards, fixtures, docs, tests that restate it) for text it now contradicts. A contradiction
  the fix creates is part of the original finding, not a new one.
- **Renamed paths:** the delta renames files or directories → build an old→new path map from the rename entries
  (`git diff -M --name-status <old_head>..<PR_HEAD>`, `R` rows), hand it to every verifier, and locate each thread's
  subject by content at its new path. A thread's `path` and `line` point at the pre-rename blob, so line matching
  marks real fixes stale and real misses fixed.
- Record each outcome as fixed / partial / unfixed with the grep that proves it.

## Where follow-ups go

- **Partial or wrong fix** → a reply on the original thread, never a duplicate top-level thread. Attach it to this
  run's pending review with GraphQL `addPullRequestReviewThreadReply` (`pullRequestReviewId` = the pending review's
  node ID) after the create POST; REST review `comments[]` cannot carry replies. The reply publishes when the user
  submits.
- A delete+recreate drops GraphQL replies → re-add every one after each recreate, then verify via
  `/reviews/{id}/comments`.
- **Live actions** (resolving a thread, emoji reactions) never ride in a pending review; they need explicit user
  consent per the Phase 2 HARD RULE and [`wk-gh`](../../gh/README.md).
