---
skill: wk-sharpen
date: 2026-06-26
type: correction
severity: low
---

A bullet/subsection merge reclaims only scaffolding bytes (~3 B), not content — size net-negative reclaims from a content cut, not a merge.

**What happened:** Folding a learning into a near-ceiling SKILL.md (48 B headroom), the planned reclaim was "merge two overlapping bullets." Measured the staged blob: still −41 over. Tried a second merge (334→335): still −38. Only a content cut (trimming a redundant restatement that the rule's own "state a rule once" sanctioned) landed it at +1. Two under-shoots before success — the measure-and-trim loop Step 7.5 forbids.

**Root cause:** Step 7.5 says "size the reclaim from a structural move (subsection merge, scaffolding/blank-line deletion)." But merging two bullets into one only deletes the `- ` prefix + one newline (~3 B) when all content words are preserved; it is not a content reduction. The rule conflates "structural move" with "byte reclaim" — a merge that keeps every word reclaims almost nothing.

**Suggested fix:** Clarify Step 7.5: when net-negative requires real bytes, the reclaim must remove **content** — a redundant-restatement trim, a relocation to `references/`, or a genuinely dropped duplicate clause — not a bullet merge that preserves all words. Estimate a merge's savings as ~3 B unless words are also cut. A pure merge counts only when paired with deleting the now-duplicated phrase.
