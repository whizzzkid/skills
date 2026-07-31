---
class: principle
---

# Keep preview URLs outside code spans

- **Rule:** Render preview paths as code-span link labels and URLs as markdown
  link destinations. Reject code-wrapped URLs in the final review payload.
- **Why:** A backtick-wrapped URL is inert, and pending review comments cannot be
  edited in place through this flow.
- **Escalation:** The faulty template predated the report and directly steered
  the failure, so its baseline rule advanced to `Important` with a pre-emit gate.
- **Rejected:** Moving the pending-review POST after CI conflicts with
  [`wk-pr`](../../pr/README.md), which launches self-review before its CI poll.
  Instead, finish known writes and re-fetch HEAD immediately before payload
  construction; later commits use the existing delete-and-repost recovery.
- **Where:** [`wk-self-review`](../README.md) preview template and POST preflight.
