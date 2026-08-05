---
class: principle
---

# Pending-review discovery expires before creation

**Rule** — Re-query the acting user's pending review immediately before create.
If a draft appeared, or create returns HTTP 422, fetch that review's body and
review-specific comments, preserve them, deduplicate their union with the
proposed draft, and only then use the replacement path.

**Why** — GitHub permits one pending review per user and an earlier discovery
read provides no lock. A long investigation leaves time for another actor or
workflow to create the draft before POST.

**Boundary** — This is concurrency recovery, distinct from create-response
parsing. Both require server re-query before any retry, but only this path must
preserve a concurrently created draft.

**Where** — `SKILL.md` → Step 3 → pending-review creation safeguards.
