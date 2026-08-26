---
skill: wk-workflow
date: 2026-08-25
type: correction
severity: medium
verified-against-source: yes
---

Re-audit every prior diff hunk for necessity after a later fix changes the reason it existed

**What happened:** The agent extracted a shared helper to deduplicate logic
between two functions (justified by a bot's code-duplication finding). A user
correction later rewrote one of the two functions so it no longer shared logic
with the other. The extracted helper's justification had silently disappeared,
but the agent left it in place — the user had to explicitly ask "why did you
modify the existing implementation if it was not needed" and demand a line-by-
line audit before the agent noticed and reverted the now-pointless extraction.

**Root cause:** The agent treated each corrective edit as a local patch rather
than re-checking whether earlier, already-applied changes were still justified
under the new state. A refactor's rationale (e.g. "removes duplication") is a
claim about the *current* diff, not a permanent property of the code — it must
be re-verified any time a later commit in the same session changes one side of
that comparison.

**Suggested fix:** After any correction that changes a function’s logic mid-
session, diff the full session's change set against the target branch and ask,
for each hunk introduced earlier in the session: "is the reason this hunk
exists still true given the latest state?" Revert or simplify any hunk whose
justification no longer holds, rather than leaving stale scope in the final
diff.
