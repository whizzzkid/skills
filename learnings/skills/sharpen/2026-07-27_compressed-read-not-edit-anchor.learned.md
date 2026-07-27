---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

An edit anchor composed from a lossy tool rendering fails the exact-match edit, and could
instead have matched the wrong span.

**What happened:** The file-read tool returned a stale-content error for a target
`SKILL.md` twice, then reported the file was unchanged since a read that had never
delivered content — so no content was ever obtained. The fallback was a shell read of the
whole file, whose output the transcript compressor then abridged: whole words were dropped
from the rendered lines ("Use reviewing authoring software architecture documents" for
"Use when reviewing or authoring…"). An `old_string` composed against that rendering did
not exist in the file and the edit failed. Recovery was a narrow ranged re-read, which
returned exact bytes.

**Root cause:** A rendering can be lossy in ways that are invisible in the rendering
itself — no marker distinguishes an abridged line from a faithful one, and abridged prose
stays grammatical enough to read as real. The skill already forbids pricing a reclaim
against a retyped or renumbered read (`byte-budget.md`: slice `old` out of the file, never
retype it; address a reclaim by content, never a carried line number), but that rule is
scoped to the byte budget. Nothing extended it to the *edit anchor*, which has the same
failure shape and a worse consequence: a mispriced budget is off by some bytes, whereas an
anchor that happens to match a different span edits the wrong text silently.

**Suggested fix:** State that any exact-match edit string must be sliced from the file by
the same match that locates the edit, never transcribed from a rendering — extend the
existing "slice, never retype" rule from pricing to anchoring, since both consume the same
bytes for the same reason. Add that a whole-file shell read is not a substitute for the
read tool when the output may be abridged: a failed or refused read must be retried as a
narrow ranged read, and a rendering that has been compressed is unusable as an edit source
regardless of how complete it looks.
