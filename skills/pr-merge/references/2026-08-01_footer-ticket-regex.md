---
class: principle
---

# Reject encoded-fragment ticket matches

**Rule** — Treat percent signs as identifier characters at ticket-key
boundaries after removing the terminal outbound footer.

**Why** — Percent-encoded metadata can place an uppercase/digit/hyphen substring
after `%`. An alphanumeric-only boundary check can still accept that fragment as
a ticket.

**Where** — `SKILL.md` Step 7 and `references/ticket-transition.md`.
