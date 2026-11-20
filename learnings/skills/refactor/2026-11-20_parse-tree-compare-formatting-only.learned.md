---
skill: wk-refactor
date: 2026-11-20
type: practice
severity: low
verified-against-source: n/a
source: learnings/retrospect/2026-11-20_session-6 (What worked)
---

Prove a "formatting-only, no behaviour change" claim by comparing parse trees, not by reading the diff.

**What happened:** A change was claimed to be formatting-only. Comparing position-stripped parse trees of the base
and head versions proved the claim mechanically. An expected structural change served as the negative control, which
showed the comparison could detect a real difference.

**Suggested fix:** For a formatting-only claim, compare position-stripped parse trees of base and head, with a known
structural change as the negative control.
