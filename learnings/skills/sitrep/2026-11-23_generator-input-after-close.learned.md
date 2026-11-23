---
skill: wk-sitrep
date: 2026-11-23
type: gap
severity: medium
verified-against-source: n/a
---

Rollover close edits the prior page, so a start generator keyed on line numbers must read the pre-close version.

**What happened:** The close step added frontmatter and heading lines to the prior page and committed it. The start generator, written against the original line numbers, then hit a handler-drift assertion and had to be resent in full because no script file is allowed. A later insertion anchored on a substring shared by two lines (a self-review count) duplicated inserted items; the post-insert count assertion caught it.

**Root cause:** The skill does not say which copy of the prior page feeds the transform after a rollover close, and line- or `data-t`-keyed edits silently shift when the close adds lines. Substring anchors that are not unique match more than one line.

**Suggested fix:** After a rollover close, save the pre-close page (or read it from the commit before the close) as the generator input, keep the close commit separate, and require every insertion anchor to match exactly one line (assert count == 1 before writing).
