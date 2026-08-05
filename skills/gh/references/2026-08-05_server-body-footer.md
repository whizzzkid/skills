---
class: principle
---

# Validate the server-returned PR body footer

**Rule** — After creating or editing a PR body, re-fetch the server-returned body and rerun footer placement checks.
Move generated reference metadata before the footer and resubmit at most once.

**Why** — Integrations can materialize Markdown reference definitions after the submitted footer.

**Where** — Step 4 footer placement post-write gate.
