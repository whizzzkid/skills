---
skill: wk-sharpen
date: 2026-08-05
type: correction
severity: medium
verified-against-source: yes
---

Validate archived source Markdown before committing its processed-state rename.

**What happened:** Retrospects were renamed and committed after repository hooks passed, but a final Markdown audit
found pre-existing lines over the project's width limit.

**Root cause:** The archive-only path treated unchanged source content as already validated and checked filenames,
staged scope, hooks, and signatures without applying the active Markdown skill to the renamed files.

**Suggested fix:** Before committing any processed-state rename, run format-specific validation on the source content
and fix violations in the same archive commit.
