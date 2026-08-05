---
skill: wk-self-review
date: 2026-08-04
type: gap
severity: low
verified-against-source: yes
---

Treat pending-review creation response fields as optional.

**What happened:** The pending review was created, but projecting `.comments[]` from the creation
response failed because GitHub returned that field as null.

**Root cause:** The post-write projection assumed the creation response embeds inline comments.

**Suggested fix:** Project only stable review fields from the POST response, then verify inline
comments through review threads before deciding whether a retry is needed.
