---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: high
---

When a block introduces a new capture variable, verify the assignment to the canonical downstream variable name appears before the block's end.

**What happened:** A PR-number inference block was refactored to capture `$PR_NUM` for guarding, but the assignment `REVIEW_PR_NUMBER=$PR_NUM` was never added. Downstream blocks (confirmation summary, payload construction) referenced `REVIEW_PR_NUMBER`, which was unset on the inferred path.

**Root cause:** Sweep 2.7 (signature widening) covers function-parameter additions but has no equivalent for "new capture variable whose value must be promoted to a canonical name downstream." The fix was mechanically obvious once spotted but was not caught by any existing mechanical sweep.

**Suggested fix:** Add a capture-variable promotion check to sweep 2.3 or 2.7: when a diff introduces `FOO=$(...)`, grep the same hunk and following lines for an assignment `CANONICAL=$FOO` or `CANONICAL="${FOO}"`. If the capture variable is local (used only in the same block for guarding) this is fine; if it feeds a downstream canonical name (visible in later hunks), the promotion assignment must be present. Detection: `git diff | grep -nE '^\+[A-Z_]+\=\$\(' | while read hit; do ...check canonical downstream...`
