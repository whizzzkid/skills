---
class: principle
skill: wk-sharpen
date: 2026-07-08
severity: low
---

- **Rule:** When proving the prohibited-term grep fires on a genuine NONE result,
  the probe token must be a literal copied from an actual `.skillprohibit` line
  (expand a regex line to a concrete match), never an invented plausible-looking
  token.
- **Why:** A probe using guessed generic tokens (a made-up employer name, a
  ticket-shaped string) matched nothing because the pattern list is machine-local
  and codename-based — the guesses were not in it. That read as "grep is broken,"
  forcing a wasted second probe with a real token before the scan could be
  trusted.
- **Where:** Step 5 overfit-scan NONE-probe bullet — required the probe token be
  copied from a real pattern line, never guessed.
