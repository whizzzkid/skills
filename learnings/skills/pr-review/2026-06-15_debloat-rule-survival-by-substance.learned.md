---
skill: wk-pr-review
date: 2026-06-15
type: pattern
severity: medium
---

Reviewing a prose-debloat PR: verify rule survival by substance, not by counting HARD RULE labels.

**What happened:** A large skill-prose debloat PR dropped `HARD RULE` label counts
sharply in rewritten files (e.g. 18→1, 28→7). The label drop looked alarming but
was stylistic consolidation — every named gate still existed as prose. Confirming
this required content-greping for each claimed gate, not counting labels.

**Root cause:** In a debloat, a label like `HARD RULE` is the first thing trimmed
even when the rule it tagged is preserved. Label frequency is a false signal for
rule loss in either direction.

**Suggested fix:** When reviewing a debloat/compression diff, enumerate the gates
the commit message claims to preserve and content-grep each against the new file.
Treat label-count deltas as noise. Caveat: with `grep -E`, write alternation as
`a|b` — `\|` matches a literal pipe and silently returns zero, which can fake a
"missing gate" finding.
