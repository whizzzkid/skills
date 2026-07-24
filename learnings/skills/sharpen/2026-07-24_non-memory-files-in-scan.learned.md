---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
---

Batch mode's Source 3 scan reports non-memory files in the memory dir as permanent un-distilled backlog.

**What happened:** A batch run diffed the full `$HOME/.claude/memory/*.md` listing against
`.distilled-memories`. Every genuine memory was already distilled, but two files surfaced as
un-distilled and always will: the memory **index** file (a hand-maintained pointer list with no
frontmatter and no `type:` field) and an append-only **retro archive** written by a different skill.
Neither can ever classify as `feedback`/`user`/`project`, so neither is processable — yet the scan
presents both as outstanding work on every single run.

**Root cause:** Source 3 globs the directory by extension and diffs paths, then filters by `type:`
only *after* a file has been selected for processing. The memory directory is not homogeneous: it
also holds an index and archives owned by other skills. Path-level diffing cannot distinguish "a
memory not yet distilled" from "not a memory at all", so the two collapse into one signal.

The gap has a second-order cost: the only way to stop the false backlog from recurring is to append
the non-memory paths to the marker — recording them as *distilled* when they were never processed.
That corrupts the tracker into a mix of real completions and suppressions, and a later reader cannot
tell which is which.

**Suggested fix:** In Source 3, filter the listing to files that actually parse as a memory before
diffing against the marker — require a frontmatter block containing a `type:` field, and drop
everything else as out-of-scope-by-rule. State that the memory directory may contain an index and
other skills' archives, and that these are excluded by the parse gate, never by a marker entry.
Add the converse rule: never write a marker entry for a file that was not processed — the marker
records distillation, and using it as a suppression list makes "already distilled" unfalsifiable.
