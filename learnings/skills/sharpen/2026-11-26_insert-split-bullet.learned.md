---
skill: wk-sharpen
date: 2026-11-26
type: correction
severity: low
verified-against-source: yes
---

A README insert cut an existing bullet in half, and nothing checked for it.

**What happened:** During a fold, new README bullets were inserted by replacing a span that ended mid-bullet. The
existing bullet's remaining sentences ("Non-actionable lines are…") ended up as the tail of the new bullet. Every
hook passed, and the defect only surfaced while the next fold was editing that same region.

**Root cause:** The edit anchor ended inside a multi-line bullet rather than at its boundary, and Step 7's drift check
compares the narrative against behavior, not bullet structure. Link and size hooks can't see a sentence moving to
another bullet.

**Suggested fix:** In Step 7 README sync, anchor every insertion on a full bullet (from its `- ` line through the line
before the next `- `), and re-read the region around each insertion. Check that each pre-existing bullet's text is
still contiguous under its own label.
