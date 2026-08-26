---
class: principle
source: learnings/skills/pr-resolve/2026-08-25_minor-bot-finding-deferred-not-fixed.md
---

# Minor severity alone does not justify deferring a cheap fix

The Minor/Info deferral rule in wk-pr-merge (Step 4) keeps low-severity
findings from blocking merge. But when the user explicitly invoked
wk-pr-resolve and the finding names a concrete, small fix, severity alone
should not defer it — classify as obvious-fix and apply inline.

Reserve deferral for findings that are genuinely low-value, ambiguous, or
high-effort — not for cheap fixes that just carry a Minor label.
