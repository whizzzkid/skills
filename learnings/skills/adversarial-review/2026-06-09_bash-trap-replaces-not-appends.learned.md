---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: high
---

When a diff adds a `trap` handler, grep the file for existing `trap` calls on the same signals — bash trap REPLACES the previous handler, so a second trap silently disables the first's cleanup.

**What happened:** Two separate review-fix rounds each added a `trap ... EXIT INT TERM` (one for an auth-header temp file, one for stderr-capture temp files). The second trap silently replaced the first, leaking the first set of temp files on interrupt — defeating the cleanup that fix existed to provide. Neither fix was wrong in isolation; the bug was the interaction.

**Root cause:** No sweep checks for multiple trap registrations on overlapping signals. Fixes applied in separate rounds each looked correct in their own diff hunk; only a whole-file view shows the collision.

**Suggested fix:** Add to mechanical sweeps: when a diff adds `trap '...' <signals>`, grep the whole file (not just the hunk) for other `trap` calls sharing any signal. Multiple traps on the same signal is a blocker — require a single combined trap or a trap-append helper. Detection: `grep -c "trap '" file` > 1 with overlapping signal lists.
