---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: high
verified-against-source: yes
---

Source 3's parse-as-memory gate under-reported on a non-unanimous split, which the existing all-or-nothing guard cannot catch.

**What happened:** A batch run's hand-rolled parse-as-memory gate accepted 3 of 9
files in the memory directory and rejected 6. Both positive controls passed (the
gate accepted a synthesized memory, rejected a synthesized non-memory), and the
verdict was not unanimous in either direction — so every existing sanity check
read green. Four of the six rejects were genuine `feedback`/`user`/`project`
memories. Only reading the rejected files revealed the fault: memory frontmatter
occurs in two shapes in the wild — a flat top-level `type: feedback`, and a
`metadata:`-nested `  type: feedback`. The gate matched the indented form only
(`^[[:space:]]+type:`), so it silently dropped every flat-form memory. Had the
run trusted the gate, those memories would have been reported as out-of-scope and
the source called drained.

**Root cause:** The existing guard is keyed on *unanimity* — "a unanimous verdict
at any Source 3 stage indicts the tooling". A shape-partial matcher produces a
partial verdict by construction: it correctly classifies the shape it knows and
silently drops the shape it does not. The more valid shapes a field has, the
further the verdict sits from unanimous, so the guard's sensitivity is inversely
proportional to the severity of the matcher's blind spot. Passing positive
controls do not help either, because a control synthesized by the same author
carries the same shape assumption the matcher does — the control and the matcher
share the defect and agree.

**Suggested fix:** In Source 3 guidance, add a rule that the parse gate must
accept **every** documented frontmatter shape for the field it keys on, and that
the memory template's own permitted shapes are the authority for that list.
Strengthen the control requirement: a positive control must be built per shape,
not per gate — one control for each frontmatter form the template allows, since a
single control only proves the matcher handles the shape the control happens to
use. Add a residual check that survives a partial verdict: any file rejected by
the parse gate whose name or path matches the memory naming convention is a
reject to eyeball, not to trust — reconcile the reject list against the
convention before treating the source as drained. State the generalization:
unanimity indicts tooling, but non-unanimity does not exonerate it.
