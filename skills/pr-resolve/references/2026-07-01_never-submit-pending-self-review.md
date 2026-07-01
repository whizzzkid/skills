---
class: principle
---

**Rule** — Never submit the author's/current-user's own pending self-review, and never re-prompt for it. Submitting is destructive and irreversible — it publishes work the human is holding for manual release (the `wk-self-review` checkpoint). "Don't bother me with it" means leave it alone, NOT submit it. Note it once, route around via the no-body GraphQL resolve path, defer the blocked replies (bots re-scan on green CI). Submit only on an explicit instruction naming "submit my review".

**Why** — A pending self-review draft by the current user blocked threaded bot replies (HTTP 422). The user said "never bother me again with a self-review posted in pending state." The agent misread "don't bother me" as "auto-submit it" and published the user's draft as a `COMMENT` event — irreversible, the opposite of intent. Escalates Hard Rule 13 from "don't re-prompt" to "never submit" — submitting was wrongly treated as non-destructive.

**Where** — `wk-pr-resolve` Hard Rule 13 + Step 3 (detail in commands.md §3).
