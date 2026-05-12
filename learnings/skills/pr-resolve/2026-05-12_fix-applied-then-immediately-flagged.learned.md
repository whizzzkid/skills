---
skill: wk-pr-resolve
date: 2026-05-12
type: gap
severity: high
---

A fix applied in the current session should not be tagged `obvious-fix` without verifying it doesn't introduce a new problem. If bots flag a fix from the same session in the very next review cycle, it signals the fix was wrong, not that the bots are noisy.

**What happened:** PR #NNN session applied a `head_branch == "null"` guard as an `obvious-fix`. In the immediately following review cycle, two Copilot threads flagged the same fix: the guard was dead code (jq `// empty` already converts null → empty upstream) and the companion bats test was simulating behavior that can't happen in production. A second session was needed to revert both.

**Root cause:** The `obvious-fix` classification skipped execution-path verification. The fix looked correct at the line level but was contradicted by the pipeline upstream of it. The "issue-class scan" rule in Step 6 looked at the PR diff for sibling instances but didn't ask "does the surrounding pipeline make this guard reachable?"

**Suggested fix:** Before tagging a defensive guard `obvious-fix` and applying it, add one mandatory check to Step 4's suggestion generation:

- **Reachability:** Trace every upstream transform on the value (jq expressions, trim, encoding) and confirm the guarded sentinel can actually reach the Rust/code layer. If an upstream stage already converts or rejects it, the guard is dead code — classify as `judgment-required` and note the reachability concern explicitly in the suggestion.

Additionally: when bots flag a finding whose `(path, line, concern)` matches a fix applied in the current session (not a prior commit), treat it as a `correction` signal, not a new independent finding. The current "already-addressed echo" rule handles re-reports of prior-session fixes; this extends it to same-session fixes that turn out to be wrong. Reply acknowledging the error, revert, and apply the correct fix — do not triage as a fresh finding.
