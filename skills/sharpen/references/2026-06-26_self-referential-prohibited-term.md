---
class: principle
---

**Rule**

When a learning's subject IS prohibited-term handling, its own worked example
is usually the prohibited term itself. Expect the renamed `.learned.md` archive
(not the skill edit) to be the blocker at the `check-prohibited` hook — scrub
the example before staging.

**Why**

The skill edit and references genericize naturally, but a learning that
illustrates a term-mechanism quotes a live `.skillprohibit` token as its
example. The `.learned.md` rename commits that archive into the public repo,
tripping the staged-set scan on the example, not on incidental prose.

**Where**

Step 5 — Mechanical overfit scan, archive-scrub bullet. Already mechanically
caught by the authoritative staged-set scan
(`grep -iEnf .skillprohibit $(git diff --cached --name-only)`); this sharpens
*where* to look first for self-referential learnings.
