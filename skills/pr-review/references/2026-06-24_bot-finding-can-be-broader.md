---
class: principle
---

**Rule:** When validating a confirmed bot finding, re-scope its severity in both
directions — not only downgrade. Trace one hop downstream for amplified impact: a
referenced file/URL/symbol that does not resolve, or a value that reaches a
user-facing surface. Impact beyond the bot's framing → "Confirmed but broader," a
reply-worthy new-evidence case.

**Why:** Bot severity can be an under-estimate. The bot's own test gap can hide the
larger impact (e.g. an enumeration test cannot catch broken doc links for variants
that are absent from the enumeration). Symmetric-only downgrade guidance lets the
true blast radius go unreported.

**Where:** Phase 2 "Re-scope a bot's severity in both directions"; Phase 4
bot-duplicate table "Confirmed but broader" row.
