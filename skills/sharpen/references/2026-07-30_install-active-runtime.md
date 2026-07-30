---
class: principle
---

# Verify the active runtime installation

**Rule** — Install for the runtime executing the skill, then byte-compare its
installed `SKILL.md` and every changed reference with repository source.

**Why** — A generic installer success marker can belong to a different agent
target while the active runtime continues executing stale instructions.

**Where** — `SKILL.md` Step 8 and the repository installer target list.

**Verification** — The package runner’s source maps its universal target to the
active canonical skill directory. Behavioral coverage requires both universal
and Claude targets, and byte comparison proves the universal copy is current.

**Byte arithmetic** — Replaced 439 B with 517 B, net +78 B: body 24329 B →
24407 B under the 24576 B ceiling. Initial 247 B headroom exceeded twice the
positive net, so no reclaim was owed. Audit cleanup measured 0 B in `SKILL.md`.
