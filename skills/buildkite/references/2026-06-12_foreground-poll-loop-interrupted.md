---
class: principle
date: 2026-06-12
---

# Never foreground-poll build status

**Rule:** Never run a polling loop (`until`/`while` on `bk build view`) in the
foreground. Run one status check and report state; watch commands that take >10s
must use `run_in_background: true`.

**Why:** A blocking poll with no timeout stalls every other action until CI
finishes (often 5–10 min) and forces the user to interrupt to regain control.

**Where:** "Monitoring Builds After Push" section.
