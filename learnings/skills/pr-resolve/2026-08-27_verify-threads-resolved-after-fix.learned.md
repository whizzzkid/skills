---
skill: wk-pr-resolve
date: 2026-08-27
type: correction
severity: medium
verified-against-source: n/a
---

Fixes were pushed but the corresponding review threads were left unresolved; the user had to ask whether the resolve step ran at all.

**What happened:** After applying fixes for {bot} findings and pushing, the run ended without marking the addressed threads resolved. The user noticed open threads and asked "did you not run the resolve skill? or did you forget to resolve those?"

**Root cause:** The skill's fix loop treated the push as the completion signal; the reply-and-resolve pass on each addressed thread was not re-verified against the live thread list after the push, so threads addressed by the fix commits stayed open.

**Suggested fix:** Add an explicit post-push verification step: re-run the unresolved-threads GraphQL query and assert every thread whose finding was fixed in this round is now resolved (reply + resolve), before declaring the round complete. A non-empty result for an addressed finding is a failure, not a report item.
