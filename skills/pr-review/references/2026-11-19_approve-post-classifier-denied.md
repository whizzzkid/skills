---
class: principle
source: learnings/skills/pr-review/2026-11-19_approve-post-classifier-denied.learned.md
date: 2026-11-19
severity: low
skill: wk-pr-review
---

**Rule** — A permission-layer denial of the approve submission is final for the run: no retry, no `COMMENT`
resubmit, no second review. The pending review already holds the comments; hand the user its URL, the payload path,
and the exact `events` POST. In auto mode with no reviews allow rule, warn in the Phase 4 summary before submitting.

**Why** — Every approve-gate precondition held and the user passed the literal `approve` token, yet the approval was
denied as self-approval. The user's opt-in does not bind the classifier; only the user (GitHub UI) or an allow rule
they add can.

**Rejected suggestion** — "stop without creating a pending draft": the skill creates the pending review first and
submits it via the `events` endpoint, so the pending review is the safe fallback, matching the gate-fails path. The
report describes a single `POST /reviews` with `event: APPROVE`, which deviates from that two-step flow.

**Where** — `SKILL.md` → Approve Flag (denial bullet); `posting-pending-review.md` → Submit as approval. Kept
consistent with `wk-pr-merge`'s auto-mode permission preflight.
