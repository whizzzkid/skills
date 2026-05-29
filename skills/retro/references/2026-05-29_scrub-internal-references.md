---
class: principle
skill: wk-retro
date: 2026-05-29
---

# Scrub internal references from the retro narrative

- **Rule:** Strip internal/code-named repos, services, bots, reviewer logins,
  SHAs/PR numbers, user-land absolute paths, and secrets before writing the
  retro entry; replace with generic placeholders.
- **Why:** The retrospect log is committed to a public repo — it must carry
  principles, not the identity of the system the session ran on.
- **Where:** Step 3 — HARD RULE "no internal references" + the validation gate
  (now also fails on user-land absolute paths).
