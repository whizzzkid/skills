---
skill: wk-pr-review
date: 2026-10-22
type: pattern
severity: medium
verified-against-source: n/a
---

The PR head can move during a long adversarial phase, so findings must be re-derived at the new head before posting.

**What happened:** During the ~10-minute adversarial run, the author pushed a commit that fixed one finding (duplicate restore) and changed the line numbers of others. The recheck before POST caught the SHA mismatch. The reviewer pulled the new head, diffed the two SHAs, re-ran the probe for the finding that survived, dropped the one that was fixed, and re-anchored every comment before posting at the new `commit_id`.

**Root cause:** Phase 3 runs long enough for authors to push. The skill says to recheck the head before POST, but not what to do when it has moved.

**Suggested fix:** When the head moved, diff old..new. Drop or adjust findings the delta touches. Re-run the probes for logic findings in changed hunks. Recompute anchor lines. Post with the new `commit_id`.
