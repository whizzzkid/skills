---
class: principle
skill: wk-workflow
date: 2026-10-30
severity: high
---

**Rule** — When a fix adds an edit that another edit depends on, name the coupling invariant, gate every edit on every
precondition before applying any of them, and fail loudly when one is missing. Add a sad-path test for each absent
precondition before committing. Treat an edit helper that silently skips a missing anchor as a red flag that needs an
explicit guard.

**Why** — A generator crashed at boot because it added a reference without the file that reference needed. The fix
added the missing file through a second injection anchored on a different line, so the two edits could apply
separately. On a target missing either anchor, the change either reproduced the crash or silently wired nothing. Both
injection helpers no-op without error on a missing anchor, which hid the gap. An automated reviewer caught it after the
push. The fix addressed the symptom but never stated the invariant the symptom proved (these lines are coupled), so
nothing enforced it.

**Where** — `SKILL.md` → Phase 2, HARD RULE "coupled edits land all-or-nothing"; summary row in
`references/edit-scope-preflights.md`.
