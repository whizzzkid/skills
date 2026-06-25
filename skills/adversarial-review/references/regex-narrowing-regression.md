---
class: principle
---

# Regex narrowing can silently regress an orthogonal axis

**Rule:** Before accepting a regex narrowed to fix one concern (greedy
overreach), enumerate the full input space — spaces, Unicode, special chars —
and confirm the narrowed form still matches them. Prefer a tail-of-line
extraction (`sed -n 's/.*anchor//p'`) over a character-class exclusion when the
value format is unconstrained.

**Why:** Narrowing `.+\.json` to `[^ ]+\.json` fixed trailing-content capture
but broke any path containing a space — the class anchor cannot bridge the
space, so the whole match fails and the extraction returns empty silently.

**Where:** Step 2 mechanical sweep 2.55(a).
