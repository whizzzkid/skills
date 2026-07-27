---
class: principle
---

**Rule** — In batch mode Source 3, gate the memory listing by parse-as-memory *before* diffing
`.distilled-memories`. A file qualifies only if it has a frontmatter block carrying a `type:` key,
matched at column 0 **or** nested under `metadata:`. Everything else is out-of-scope-by-rule and
never a marker entry. Never write a marker entry for a file the run did not process.

**Why** — The memory directory is not homogeneous: it also holds a hand-maintained index file (no
frontmatter at all) and another skill's append-only archive. Path-level diffing collapses "a memory
not yet distilled" and "not a memory at all" into one signal, so those residents surface as
permanent backlog on every run. The only way to silence them without a parse gate is to append their
paths to the marker — which records them as *distilled* though they were never processed, turning
the tracker into an unreadable mix of real completions and suppressions.

**Where** — Batch Mode → Source 3 (global memory files), alongside the path-normalization rule.

**Rejected suggestion (do not re-propose)** — The field report's fix required "a frontmatter block
containing a `type:` field", which reads as a column-0 `^type:` match. Verified against the actual
store: genuine `feedback` memories nest the key as `metadata:` → `type:`, so a bare `^type:` grep
drops real memories while admitting none of the residents it was meant to exclude. Relaxing the
gate to "has any frontmatter" was also rejected — it would re-admit any future non-memory resident
that happens to carry a header.

**Amended after a re-violation** — this note originally closed with "the gate must accept the
nested form", which reads as though *nested* were the canonical shape. A later run obeyed that
emphasis literally, built an indented-only matcher (`^[[:space:]]+type:`), and silently dropped
every flat-form memory — the same defect this note records, with inverted polarity. The rule is
**symmetric**: both shapes occur in the store and the gate must accept **both**; a matcher keyed on
either one alone is broken. Do not restate the requirement in a way that privileges one shape.
