---
class: principle
---

# Inline generator shape, and patching the page without losing escapes

**Rule** — Two additions to the inline span generator rule:

- **Patch without eating `\#`.** A later in-place patch of `live.md` (for example recording Stage 7 launches) replaces
  the target line via shell parameter substitution on the file contents, never a `sed`/`awk` replacement — both treat
  `\#` in the replacement string as an escaped `#` and drop the backslash, silently re-exposing the hashtag to
  SilverBullet. Compare the `\#` count before and after the patch.
- **Replace the Auto-Actions placeholder in place.** Stage 7 runs after the page is written, so launched reviews
  replace the section's placeholder line rather than being appended next to it.

**Why** — Verified: `sed "s/X/$new/"` and `awk sub()` both turn `repo\#NNN` into `repo#NNN`; zsh/bash
`${content/X/$new}` keeps it. An appended list leaves a stale placeholder contradicting the items beneath it.

**Generator shape (mechanical, not promoted)** — The working shape passes the `jq` program through a command
substitution around a quoted heredoc and the item data on stdin from a second quoted heredoc, so no script file is
written (write-scope HARD RULE). Lift the copy-block markup from the previous page with `grep` rather than retyping it.
Smoke-test the program on empty data first; any scratch output written inside the sitrep directory for that test is
deleted immediately.

**Already covered** — The generator rule itself (`SKILL.md` Stage 4 *Generate spans; never hand-type them*, installed
2026-10-22) fired correctly in the reporting run (66-item page rendered first time), so no escalation.

**Where** — `SKILL.md` → `start` Stage 4 → *Patch lines without eating `\#`*; Stage 7 placeholder clause;
`rendering-contract.md` escaping bullet; `auto-review.md` → Render.
