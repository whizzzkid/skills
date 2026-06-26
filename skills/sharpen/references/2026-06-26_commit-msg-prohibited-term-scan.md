---
class: principle
---

**Rule:** When recording a skipped or private-routed fold (prohibited-subject gate),
name the subject by category only in the commit-message body — never the token.

**Why:** The `commit-msg` hook scans the message with the same term list as staged
files. The natural way to document "why this fold was skipped" reintroduces the exact
token the gate just removed, failing the commit and forcing a re-author cycle.

**Where:** Step 3 prohibited-subject gate HARD RULE. Distinct surface from the Step 5
staged-file scan, which covers files but not the commit message.
