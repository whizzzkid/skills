---
skill: wk-sharpen
date: 2026-06-26
type: pattern
severity: low
---

When the target skill has an extended-catalog references pointer, route a new table row there instead of fighting the body ceiling inline.

**What happened:** Folding a new mechanical-sweep row into a skill with <333 B body headroom, the trimmed inline row still measured 315–502 B — every inline placement either blew the ceiling or left a single-digit margin that the tight-headroom reclaim rule forbids. Writing the full row into the existing `references/*-extended.md` catalog and appending only its ID to the inline pointer list added ~6 B to the body.

**Root cause:** Step 7.5 prefers content-removing structural moves, but the default instinct is still to place a new row in the inline table next to its siblings, then reclaim. For a skill that already maintains an extended-catalog pointer, the structural move is the *first* option, not the fallback.

**Suggested fix:** In Step 4/7.5, when the edit is a new catalog/table row AND the skill maintains a `references/` extended file with an inline ID pointer list, draft the row directly into the extended file and add only its ID to the pointer — body cost is the ID token (~6 B), no reclaim needed. Reserve inline placement for rows that must sit beside a specific sibling for legibility.
