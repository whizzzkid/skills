# Review clearance lineage

Review identity follows the reviewed body of work, not commit SHA equality.

## Classify the delta

Compare HEAD with the newest clear or blocked review record:

- Same SHA → reuse the record.
- `git diff --quiet <reviewed-sha> HEAD` succeeds → tree-identical rewrite;
  carry the record across a rebase, force-push, or commit rewrite.
- Every changed hunk maps to an originating recorded finding or review thread,
  with no new scope, refactor, or unrequested logic → finding-response delta.
- Any unmatched change → lineage break.

## Act on the classification

- Clear record + preserved lineage → carry clearance; no review invocation.
- Blocked record + finding-response delta → validate only recorded findings.
  Skip the sweep catalog and subagent. All fixed → write a clear record for HEAD.
- Lineage break → completion gate runs one review over
  `git diff <delta-base>..HEAD`; batch all unmatched work.

## Resolve the delta base

- `git merge-base --is-ancestor <reviewed-sha> HEAD` succeeds → delta base = `<reviewed-sha>`.
- Fails (rebase/force-push) → never diff from `<reviewed-sha>`: across a rebase that range spans every base-branch
  change. Map the last reviewed PR commit to its rebased copy in `git log --no-merges <base>..HEAD` — match
  `git patch-id --stable` first, subject line as fallback — and use that copy as the delta base.
- No rebased copy found → treat the whole PR (`<base>...HEAD`) as unmatched work.
- Merge and other readers never dispatch. Missing record or lineage break returns
  to the completion gate.

## Record enough evidence

- Clear record: SHA, base, timestamp, verdict, counts, finding fingerprints.
- Blocked record: same metadata plus each finding's reproducer and fix sketch.
- Match every exempt commit or hunk to that evidence. No match means new work.
