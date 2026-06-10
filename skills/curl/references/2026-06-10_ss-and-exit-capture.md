---
class: principle
date: 2026-06-10
severity: high
---

- **Rule:** Any curl call whose response is parsed uses `-sS` (never bare `-s`)
  and captures `$?` immediately, branching on exit status before parsing the
  body; credentials are referenced via `$TOKEN` in the header, never inlined.
- **Why:** `-s` swallows curl's transport-error diagnostic, so a DNS/TLS/
  connection failure yields empty stdout and a misleading parse error; an
  inline token leaks via `ps` and shell history.
- **Where:** New skill `wk-curl` — three HARD RULEs (`-sS`, exit-capture, token
  hygiene). Seeded the skill per the wk-learn tool-routing rule.
