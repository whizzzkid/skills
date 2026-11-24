---
class: principle
source: learnings/skills/pr-review/2026-11-24_open-url-denied-auto-mode.learned.md
date: 2026-11-24
severity: low
---

## A denied `open` falls back to printing the URL

- **Rule:** If the Phase 5 `open <html_url>` is denied by a permission layer, print the `html_url` in the terminal
  summary and move on. Never retry it or work around the denial.
- **Why:** The open-URL HARD RULE assumed `open` is always available. In auto mode a classifier denied it as an
  outward-facing action after the review was already submitted, so only the browser tab was lost.
- **Where:** `SKILL.md` Phase 5 open-URL HARD RULE; mechanics in [`permission-denials.md`](permission-denials.md).
