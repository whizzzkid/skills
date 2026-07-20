---
skill: wk-sharpen
date: 2026-07-20
type: pattern
severity: low
---

A prior session's partial fold left in the working tree may be misguided — evaluate it against the lesson before building on it.

**What happened:** The target `SKILL.md` arrived with an unstaged edit from an earlier session (a redundant tool-allowlist entry) that purported to fix a host permission-classifier denial. The entry was both redundant with the bare tool already listed and powerless against the classifier (a separate host layer). Distilling correctly required reverting it, not extending it.

**Root cause:** wk-sharpen reads the full skill but has no explicit step to treat pre-existing uncommitted edits as suspect. A partial fold can encode the wrong mental model (here: that a skill's `allowed-tools` governs the host classifier).

**Suggested fix:** In Step 2/Step 5, when the target file has uncommitted changes not made this run, verify each against the distilled lesson; revert edits that do not actually address the root cause rather than committing them alongside the real fix.
