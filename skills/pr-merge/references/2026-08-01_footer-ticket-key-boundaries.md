---
class: principle
---

# Ignore transport metadata during ticket-key detection

**Rule** — Strip the terminal canonical outbound footer before scanning a PR
body, then accept only boundary-delimited ticket keys.

**Why** — Timestamped links and other generated metadata can contain an
uppercase/digit/hyphen substring that satisfies a broad key regex. Parsing the
rendered body without boundaries turns transport metadata into a false ticket.

**Where** — `SKILL.md` Step 7 and `references/ticket-transition.md`.
