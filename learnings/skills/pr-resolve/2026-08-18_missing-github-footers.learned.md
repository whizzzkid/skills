---
skill: wk-pr-resolve
date: 2026-08-18
type: correction
severity: high
verified-against-source: yes
---

GitHub outbound messages must include the canonical footer.

**What happened:** GitHub PR description edits, PR comments, and attempted review-thread replies were rendered without the required outbound footer.

**Root cause:** The workflow performed payload construction and GraphQL/REST mutations without a final footer-rendering gate immediately before each outbound request.

**Suggested fix:** Require a mechanical preflight for every GitHub mutation: classify the payload surface, append the canonical footer exactly once, lint the rendered body, then send it. Apply this gate independently to PR-body edits, issue comments, threaded review replies, dismissal bodies, and follow-up messages; never treat a prior footer on a different surface as satisfying the current mutation.
