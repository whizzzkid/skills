---
skill: wk-self-review
date: 2026-05-15
type: correction
severity: medium
---

Verify self-review comment lines are within diff hunks before POSTing.

**What happened:** The first self-review API call returned HTTP 422 "Line could not be resolved." The line numbers used were absolute file line numbers, not diff-hunk lines. GitHub only accepts line numbers that appear in the PR's diff.

**Root cause:** The skill says to use file line numbers but GitHub's review API requires lines reachable via the diff. For new files and changed hunks, the new-file line number must fall within a `@@` hunk range.

**Suggested fix:** Before POSTing the review, run `git diff origin/<base>...HEAD -- <file>` and extract the `+N,M` ranges from each `@@` line. Only comment on lines within those ranges. If the ideal comment line falls outside all hunks, use the nearest in-hunk line or fall back to a file-level comment (omit `line` and `side`).
