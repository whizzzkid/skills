---
skill: wk-pr-review
date: 2026-11-24
type: pattern
severity: medium
verified-against-source: n/a
---

On re-review, verify every "fixed" reply against the head blob with a mechanical check per finding, and treat a deferral without a tracking link as still open.

**What happened:** The author replied "fixed" on nine threads. Per-finding greps at head showed six fully fixed, two partial (a replaced reference pointed to the wrong rule; the same sentence kept two other undefined references), and one deferred with no tracking link. The user had asked to confirm fixes landed rather than trusting replies.

**Root cause:** The re-review step says a modified file proves an attempt, not a fix. But it doesn't say to (a) re-grep the whole file for the same pattern, since a fix often lands only on the quoted instance, or (b) count a fix-induced inconsistency as part of the original finding. Here, adding a data class to a severity list made older cards contradict it.

**Suggested fix:** In Phase 2 re-review, for each "fixed" reply run a pattern-level check over the changed file and its siblings, not just the quoted line. Also diff the delta for rules it newly tightens, and grep the dependent artifacts (cards, fixtures) for contradictions it creates. A partial fix goes in as a reply on the original thread, added to the pending review through the GraphQL review-thread-reply mutation, never as a duplicate new thread.

Also: a create-review POST can return HTTP 502 and still create the review. Always list pending reviews before retrying, or the retry 422s or doubles the review.
