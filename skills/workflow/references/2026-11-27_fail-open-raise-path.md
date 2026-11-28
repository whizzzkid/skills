---
class: principle
---

# A fail-open promise needs a call-site rescue and a raise-stubbing spec

- **Rule:** A "never blocks the caller" promise is an "every path" invariant whose raised-exception cell must be
  listed: wrap the whole dependency interaction (construction, call, result handling) in one call-site rescue of the
  standard error base, and spec a stubbed raise next to the returned-failure stub, before the first push. Every layer
  of a stack gets its own independent review, the first layer included.
- **Why:** A fail-open deploy step checked only the dependency's returned failure and trusted its internal rescue. A
  raise from the constructor, or from an API renamed later, would still abort the deploy; the specs stubbed only
  returned failures, so they shared the blind spot. That layer was also the one in its stack that skipped independent
  review, and a review bot caught the gap after publishing.
- **Escalation (re-violation):** both installed rules were re-violated, so each moved one rung, baseline to
  `Important`: the Phase 3 termination-matrix rule (installed 2026-11-04, its cell list already named "uncaught
  exception") and the Phase 5 rule that each stacked PR completes Phases 5→6.5 on its own.
- **Where:** API mechanics → [`wk-workstyle-error-handling`](../../workstyle-error-handling/README.md) Rules
  (fail-open call-site rescue). Escalations → [`wk-workflow`](../README.md) Phase 3: Test and Phase 5: PR.
- **Rejected:** a separate fail-open bullet in `wk-workflow` Phase 3. The termination matrix already covers the
  raised-exception cell, and the body sits at its byte ceiling; the rescue mechanics belong to the error-handling
  skill, which auto-invokes on the error-return edit.
