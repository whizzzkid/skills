---
class: principle
---

**Rule:** To check SKILL.md size headroom, run the size hook's `measure()`
function verbatim — copy it from `.githooks/check-skill-size.sh`. Never use
`wc -c`, a fresh awk, or an abbreviated replica.

**Why:** An abbreviated awk that omits the `state="pre"` init counts the
front-matter block as body, reporting false (often over-ceiling) headroom. The
wrong number is internally self-consistent, so it looks plausible and is trusted.

**Where:** wk-sharpen Step 7.5, "measure exactly once" sub-bullet. Escalated
`**Important**` → `**Very important**` after a re-violation: the prior text
shipped an abbreviated awk snippet as its own example, inviting the bug.
