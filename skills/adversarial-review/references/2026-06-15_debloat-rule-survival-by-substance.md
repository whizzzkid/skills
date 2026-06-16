---
class: principle
date: 2026-06-15
---

# Verify debloat-diff rule survival by substance, not label counts

**Rule:** When investigating a prose-compression/debloat diff, verify rule
survival by *substance*: enumerate each gate the commit claims to preserve and
content-grep it against the new file. Treat `HARD RULE` (or similar) label-count
deltas as noise. With `grep -E`, write alternation as `a|b` — `\|` matches a
literal pipe and silently returns zero, faking a "missing gate".

**Why:** A label like `HARD RULE` is the first thing trimmed in a debloat even
when the rule it tagged is preserved, so label frequency is a false signal for
rule loss in either direction. (Originated in wk-pr-review; folded into the
adversarial-review investigation that wk-pr-review now delegates to.)

**Where:** Step 5 → "Documentation / prose / compression diffs" →
Compression/debloat diffs bullet.
