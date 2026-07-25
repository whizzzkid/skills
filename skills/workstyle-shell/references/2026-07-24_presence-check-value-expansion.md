---
skill: wk-workstyle-shell
class: principle
---

**Rule** — Presence-check a variable with a test builtin, never a parameter-default
expansion. `${VAR:-x}` / `${VAR-x}` substitutes the default only when the var is
*unset*; on the set path it emits the value. Fingerprint (length + hash prefix) when a
value must be compared across two lookups.

**Why** — `${VAR:+flag}${VAR:-NO}` reads as a two-branch ternary but is two independent
expansions, and the set path — the common one — writes the value verbatim to whatever
reads stdout. For a credential that is a disclosure requiring rotation, and the bug is
invisible on inspection because the intent (presence) and the mechanism (expand the
value) never appear on the same line. Verified by reproduction: with the var set, the
paired form prints `yes<value>`.

**Where** — wk-workstyle-shell Rules; the consuming instance corrected in the same pass
was an env-diagnostic report that printed a value prefix for every set var.
