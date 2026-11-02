---
skill: wk-pr-review
date: 2026-11-02
type: gap
severity: low
verified-against-source: n/a
---

A pending draft from the current user that a previous session left at the same head should be folded into the new review.

**What happened:** Phase 2 found the user's own pending review from an earlier interrupted run, at the same head SHA. Its inline comments came back with `line: null`. The run re-verified those findings, merged them into the new set, then deleted the old draft and recreated the review.

**Root cause:** The skill covers appending to a pending review, but it does not say what to do with a stale own draft found at the start of a run.

**Suggested fix:** In Phase 2, detect an own pending review. If it is at the same head, treat its comments as candidate findings to re-verify, not as an exclusion list. Then delete it and recreate it through the append path.
