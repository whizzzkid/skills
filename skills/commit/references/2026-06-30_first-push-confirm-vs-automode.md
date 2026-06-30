---
class: principle
---

**Rule:** Scope the first-push-of-a-new-branch confirmation to genuinely
ambiguous intent. When auto mode is on *and* the session's originating prompt
already authorizes a published/tracked PR (e.g. "create a ticket to track this",
"open a PR", "ship X"), skip the confirm and push. The no-upstream signal alone
does not mean unclear intent.

**Why:** The confirm rule reads as unconditional, but firing a permission prompt
after the user's own directive already authorized a tracked change re-litigates
approval the directive already gave — the user pushes back with "why do you keep
confirming?". The branch-with-no-upstream state is *expected* under such a
directive, not a surprise.

**Where:** wk-commit push section, first-push bullet + the push-decision table
row. Same lesson surfaced in a session retro's "What could've been better".
