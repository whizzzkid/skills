---
skill: wk-pr-resolve
date: 2026-08-25
type: correction
severity: medium
verified-against-source: n/a
---

Hard Rule 9's co-author trailer conflates PR authorship with commit authorship

**What happened:** The skill's Hard Rule 9 says "current user not the PR author → add a Co-authored-by trailer for the PR author on every commit." Applied literally, this proposed adding `Co-authored-by: {PR author}` to commits the PR author never touched (agent-authored lint/merge fixes). The user rejected this: the PR author didn't write those commits, so crediting them as co-author misattributes the change.

**Root cause:** The rule's trigger condition ("current user != PR author") is necessary but not sufficient — `Co-authored-by` is a claim about who contributed to *this specific commit's content*, not who owns the PR/branch it lives on. The rule as written fires on PR ownership alone, with no check for actual content contribution (e.g., incorporating a suggestion the PR author wrote, pairing, or applying their patch).

**Suggested fix:** Narrow Hard Rule 9 to only apply when the commit's content actually originates from or incorporates the PR author's work (e.g., applying a suggested-change diff they wrote, or a review comment's proposed patch). For commits that are purely agent-authored fixes on someone else's branch (lint, merge conflict resolution, CI fixes), omit the trailer — only `Assisted-by: Claude` (or equivalent) applies, since that credits the tool, not a human contributor who didn't write the change.
