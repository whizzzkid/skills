---
class: principle
---

**Rule:** When the edit is a new catalog/table row AND the skill already maintains
a `references/` extended file with an inline ID pointer list, draft the row directly
into the extended file and add only its ID to the inline pointer (~6 B body cost).
Make this the first choice — never place the row inline, then reclaim. Reserve inline
placement for rows that must sit beside a specific sibling for legibility.

**Why:** Folding a new mechanical-sweep row into a near-ceiling body, the trimmed
inline row still measured well past the available headroom — every inline placement
either blew the size ceiling or left a single-digit margin the tight-headroom reclaim
rule forbids. Routing it to the extended catalog costs only the ID token, no
measure-and-trim cycle. Step 7.5 already prefers content-removing structural moves for
*existing* rows; the gap was treating that move as the first option for a *new* row in
a skill that maintains an extended pointer, not a post-overflow fallback.

**Where:** Step 7.5, de-bloat structural-moves bullet (1).
