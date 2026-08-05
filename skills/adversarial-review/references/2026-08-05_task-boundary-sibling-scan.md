---
class: principle
---

# Sweep raw invocations when a task registry becomes authoritative

**Rule** — Grep workflows, setup/help text, and source comments for the raw command. Require only the authoritative
registry or wrapper definition to retain it.

**Why** — Auditing only the changed workflow leaves sibling jobs and contributor instructions on the bypassed path.

**Where** — Mechanical sweep 2.2.
