---
class: principle
skill: wk-plan
date: 2026-06-23
---

**Rule**

When a ticket key is in scope, surface its lifecycle transitions (claim → In
Progress, PR-opened comment, In Review, Done) as named numbered plan steps —
not invisible side-effects delegated wholly to the ticket-sync skill. Mark each
`[AGENT-READY]` with the caveat that auto mode may block the write.

**Why**

A transition handled only as an ambient side-effect is invisible in the plan and
prone to being skipped or blocked without the user noticing. An explicit plan
step gives a denied auto-mode write something concrete to retry against.

**Where**

Step 3 mandatory plan elements (element 9, conditional on ticket in scope) and
the Step 4 mandatory-elements validation check.
