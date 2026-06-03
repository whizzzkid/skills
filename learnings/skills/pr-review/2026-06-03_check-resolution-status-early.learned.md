---
skill: wk-pr-review
date: 2026-06-03
type: gap
severity: medium
---

On a re-review, query each review thread's `isResolved` status in Phase 2 — before planning loop-closure work.

**What happened:** A re-review treated all prior comments (mine + bot findings) as active and planned acknowledgment replies, 👍 reactions, and resolve-with-consent flows for each. Only after reading every file and validating fixes did a GraphQL `reviewThreads { isResolved }` query reveal 6 of 7 threads were already resolved by the author. The loop-closure prep was wasted; the re-review collapsed to a one-line LGTM plus one genuinely-open thread.

**Root cause:** Phase 2 fetches inline comments via the REST `/pulls/{n}/comments` endpoint, which carries no resolution state. Resolution status (`isResolved`) is only available via the GraphQL `reviewThreads` query, and the skill positions that query later (resolve step), not at intake. So the re-review classifier in Phase 2 cannot distinguish "active thread needing follow-up" from "author already fixed and resolved."

**Suggested fix:** In Phase 2, run the GraphQL `reviewThreads { id isResolved isOutdated comments }` query at intake and annotate each thread with its resolution state. Skip loop-closure planning (acknowledgments, reactions, resolve prompts) for threads already `isResolved: true` — they need no action. Reserve re-review follow-up work for threads that are open OR resolved-but-the-fix-doesn't-hold. This avoids preparing live actions for threads GitHub already considers closed.
