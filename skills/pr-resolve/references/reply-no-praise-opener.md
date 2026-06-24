---
class: principle
---

**Rule:** Every GitHub reply/dismissal body must open with substance — what
changed, the decision, or the commit SHA. Praise / thanks / acknowledgement
openers ("Good catch!", "Great point!", "Thanks!") are banned unconditionally,
including in short review-thread replies.

**Why:** Routing replies through `wk-tone` is a process step the agent can skip
("it's just a review reply"), and it did — a praise opener shipped despite the
existing routing gate. Encoding the ban at the content level (name the forbidden
openers inline) makes it enforceable even when the routing step is missed.

**Where:** Hard Rule 2, pr-resolve — added as a content-level gate alongside the
wk-tone routing rule it backstops.
