---
class: principle
date: 2026-05-27
source: learnings/skills/pr-resolve/2026-05-27_skip-step7-confirmation.md
severity: medium
---

- **Rule:** Step 5's per-comment decisions are the explicit user authorization required by Hard Rule 1. Skip the Step 7 "Proceed? (yes / edit / abort)" gate by default and proceed directly to Step 8; emit the gate only when the session contains a `(e)` edit whose adjustment was not echoed back for review, a co-author session with inferred attribution, or a collapsed batch decision.
- **Why:** Re-asking for confirmation after every decision was already collected one-at-a-time forces the user to type `yes` for ceremony and adds latency to a fully-authorized run.
- **Where:** Step 7 — new "HARD RULE: Skip the confirmation gate when Step 5 decisions are explicit" block; the existing prompt fires only when the listed conditions match.
