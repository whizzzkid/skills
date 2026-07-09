---
skill: wk-pr-resolve
date: 2026-07-09
type: gap
severity: medium
---

Default should be to resolve a thread immediately after posting a reply that answers/fixes the finding, without a separate confirmation ask.

**What happened:** After posting fix-confirmation replies to several review-comment threads, the agent asked the user whether to also resolve those threads, treating resolution as a distinct step requiring its own go-ahead.

**Root cause:** Existing guidance (only resolve threads actually worked on) correctly scopes *which* threads may be resolved, but under-specifies *when* — it doesn't state that a reply which itself answers or fixes the finding should trigger immediate resolution as the default action, rather than a follow-up question.

**Suggested fix:** Once a reply is posted that answers or fixes a finding, resolve that thread in the same action, with no separate confirmation prompt. Only leave a thread open when the remaining content is a genuine follow-up question needing more discussion — that is the one case to hold open and surface to the user.
