---
class: principle
---

**Rule:** When a browser-automation session verifies rendered output, close/dispose
it immediately after reading the assertion — before any user-facing `open`.

**Why:** The verification session and the user-facing tab have distinct lifecycles;
leaving the automation/headless window open clutters the desktop with an
unexplained window the user must close manually.

**Where:** Stage 5 render-verification HARD RULE.
