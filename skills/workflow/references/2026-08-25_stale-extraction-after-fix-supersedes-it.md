---
class: principle
source: learnings/skills/workflow/2026-08-25_stale-extraction-after-fix-supersedes-it.md
---

# Re-audit earlier hunks when a correction changes their justification

When a user correction rewrites a function mid-session, re-check whether
earlier session changes (extracted helpers, added abstractions) are still
justified. A refactor's rationale ("removes duplication") is a claim about
the current diff, not a permanent property — it must be re-verified when a
later commit changes one side of the comparison.

After any correction that changes a function's logic, diff the full session
change set against the target branch and ask for each hunk: "is the reason
this hunk exists still true given the latest state?" Revert or simplify any
hunk whose justification no longer holds.
