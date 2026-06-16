---
class: principle
---

**Rule**

When the diff introduces or renames a default/fallback constant, grep all files
for string literals describing the OLD default behavior (the prior name, "no
model", "default") and verify each is updated or intentionally kept. Sweep 2.38.

**Why**

A call-site-only sweep misses display-label and logging helpers that hard-code
the old representation. A logging path emitting the stale name reads as a correct
value to operators at runtime.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.38.
