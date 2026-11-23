---
class: principle
skill: wk-gh
date: 2026-11-20
---

# Re-violation: a GraphQL reply joined a pending self-review

- **Rule:** Before a GraphQL thread reply, query the acting user's reviews for a PENDING one; resolve the thread only
  once the reply is visible. Escalated one rung (baseline → `Important`) in Step 3.
- **Why:** The existing rule (installed before the incident) said to check for pending reviews before GraphQL replies,
  but it did not fire: a self-review was staged, then `addPullRequestReviewThreadReply` returned a reply whose
  `pullRequestReview` was that PENDING draft, so it stayed invisible. A repeat of an installed rule is escalation
  evidence.
- **Where:** `SKILL.md` → Step 3 (Canonical surface for GitHub writes). Source: gh learning and the session-9
  retrospect.
