---
skill: wk-adversarial-review
date: 2026-06-01
type: correction
severity: medium
---

Distinguish pre-existing relocated code from net-new issues when rating severity.

**What happened:** A subagent rated `realpath` as a blocker on macOS, and flagged
`wc -l` leading-whitespace brittleness and a glob-pattern injection concern. All
three were verbatim lifts from a prior commit — already present in the test shim
at merge-base. The refactor moved them without modification; none were introduced
by the diff.

**Root cause:** The subagent hunted against the full diff including removed→added
lines for a pure move (refactor), not scoped to lines net-new to the branch. A
"same code, new file" move looks like a new introduction if the prior location is
not checked.

**Suggested fix:** Before rating a finding as a blocker in a refactor-dominated
diff, require Step 1's diff map to annotate each hit as net-new vs relocated.
For relocated lines, check whether the same line existed at merge-base; if yes,
downgrade to suggestion or skip (the issue was accepted before this branch).
