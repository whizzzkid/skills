---
skill: wk-workflow
date: 2026-10-30
type: correction
severity: high
verified-against-source: yes
---

A fix that adds a second edit to the same file must make both edits land together or not at all, when one is
useless or harmful without the other.

**What happened:** A generator's boot crash came from a reference added without the file it needed. The fix added a
second, independent injection anchored on a different line. The two edits could now apply separately, so a target
file missing either anchor would reproduce the original crash or silently wire nothing. An automated reviewer caught
it after the push, and the user rightly called it out as something to get right the first time.

**Root cause:** The fix was scoped to the symptom (add the missing piece). It never restated the invariant the symptom
proved, which is that the two lines are coupled, and never checked that the new code enforces it. Both injection
helpers silently no-op on a missing anchor, which made this easy to miss.

**Suggested fix:** In Phase 2's edit-scope pre-flights, add: when a fix introduces an edit that another edit depends on,
name the coupling invariant and gate both edits on every precondition up front (all-or-nothing). Add a sad-path test
for each precondition being absent before committing. Treat "edit helper skips silently on a missing anchor" as a red
flag that needs an explicit guard.
