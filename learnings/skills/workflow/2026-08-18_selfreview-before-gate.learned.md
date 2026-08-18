---
skill: wk-workflow
date: 2026-08-18
type: gap
severity: medium
verified-against-source: n/a
---

Phase ordering stages the self-review before the adversarial-review gate, so on any PR whose review yields fixes the self-review anchors are stale by construction.

**What happened:** The workflow ran self-review at its ordered phase (before publish), then the
adversarial-review gate ran after ready and produced two findings. Fixing them created a commit
that rewrote the file one staged comment anchored to, so the pending review had to be deleted
and re-staged. The stale-anchor handling lived only in the self-review skill's recovery path,
so nothing in the phase sequence flagged it.

**Root cause:** The phase order assumes the review gate produces no commits. Whenever it does —
the common case for a non-trivial diff — the earlier self-review phase output is invalidated,
and no phase owns re-anchoring it.

**Suggested fix:** Add an explicit re-anchor checkpoint after the review-gate fix loop: if any
commit landed since the self-review was staged, re-run the self-review staging step (or its
drift check) before handing the PR over. Alternatively move the self-review phase to after the
gate clears, so it is staged against a settled HEAD once rather than staged and repaired.
