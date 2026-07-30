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
  `git diff <reviewed-sha>..HEAD`; batch all unmatched work.
- Merge and other readers never dispatch. Missing record or lineage break returns
  to the completion gate.

## Record enough evidence

- Clear record: SHA, base, timestamp, verdict, counts, finding fingerprints.
- Blocked record: same metadata plus each finding's reproducer and fix sketch.
- Match every exempt commit or hunk to that evidence. No match means new work.
