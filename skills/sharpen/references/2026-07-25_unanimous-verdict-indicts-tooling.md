---
class: principle
---

**Rule** — At *any* stage of the memory scan (Source 3), a unanimous verdict indicts the
tooling before the files, in **either** direction:

- Parse gate rejects every candidate → suspect the matcher. Drive it against one input
  known to parse before believing the zero.
- Marker diff shows every item un-distilled → suspect a path-format mismatch.

A hand-rolled filter's zero closes out a source only after a positive control moves its
count.

**Why** — The two stages have symmetric failure modes but fail in **opposite**
directions, so the pre-existing marker-diff warning does not generalize to the parse gate
by analogy. All-un-distilled over-reports work — noisy, self-correcting, and it prompts an
investigation. All-reject under-reports it: the source reads "no memories to process", the
queue looks drained, and the run produces no visible work, so nothing signals that
anything went wrong. A false *empty* is the more dangerous half, and it was the unguarded
one — the parse gate was added after the marker-diff warning and inherited no equivalent
check.

**Where** — wk-sharpen batch mode, Source 3; expanded mechanics in
`references/memory-marker-diff.md`.

**Related** — the concrete matcher defect that exposed this gap is a silent POSIX/PCRE
escape mismatch, distilled into the shell-workstyle skill; this fold covers the missing
*sanity check*, not the matcher bug.
