---
class: principle
---

# New same-type struct field must inherit its siblings' sanitization

**Rule**

- When a new field is added to a struct/record alongside an existing field of the
  same primitive type, grep for any resolver/normalizer/sanitizer applied to the
  sibling (`resolve*`/`normalize*`/`sanitize*`, often at load time) and confirm the
  new field receives equivalent treatment.
- Absence is a blocker when the field feeds a security-sensitive consumer (file
  paths, URLs, shell args, allow-dir lists).

**Why**

- A new `Scope string` added beside an already-normalized `Model string` was passed
  raw to its consumer because no `resolveCheckScope` mirrored the existing
  `resolveCheckModel` — opening a path-traversal vector.
- Widening sweeps (caller updates, struct-field assertions) check that callers and
  tests exist; none asked "does the new field need the same normalization as its
  same-type siblings?" The symmetry was implicit.

**Where**

- `skills/adversarial-review/SKILL.md` Step 2 sweep 2.43.
