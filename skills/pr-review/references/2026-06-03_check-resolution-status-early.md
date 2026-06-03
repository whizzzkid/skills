---
class: principle
---

- **Rule:** On a re-review, query each thread's `isResolved` via GraphQL `reviewThreads` at Phase 2 intake; skip loop-closure planning for threads already `isResolved: true`.
- **Why:** The REST `/pulls/{n}/comments` endpoint carries no resolution state, so a re-review classifier treats author-resolved threads as active and wastes work preparing acknowledgments, reactions, and resolve prompts for closed threads.
- **Where:** Phase 2, new "Fetch thread resolution state (re-review intake)" subsection.
