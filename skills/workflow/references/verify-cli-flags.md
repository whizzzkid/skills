---
class: principle
---

**Rule**

Verify any CLI flag against the tool's `--help` before embedding it in a doc,
skill, or committed script.

**Why**

An unverified or stale flag name fails on first run with `flag provided but not
defined` (exit 2). A wrong flag baked into a global instruction breaks every
invocation until someone reads the help output.

**Where**

`skills/workflow/SKILL.md` → Code Standards.
