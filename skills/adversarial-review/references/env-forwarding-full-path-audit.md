---
class: principle
---

**Rule**

Sweep 2.20 must escalate beyond the diff delta. When the diff touches a compose
`environment:` block or plugin `env:` array, grep the entire container runtime call
graph (every script AND called library) for env reads and diff that whole set against
the forwarding list; run a sibling-template consistency check.

**Why**

The original sweep checked only net-new env reads introduced by the diff, so pre-existing
reads in libraries called by the changed script were missed. Forwarding gaps fail silently
at container runtime. Siblings serving the same role must forward the same logical set.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.20.
