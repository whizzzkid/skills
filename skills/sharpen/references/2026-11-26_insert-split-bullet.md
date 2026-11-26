---
class: principle
skill: wk-sharpen
date: 2026-11-26
severity: low
---

# Insert into a list on whole-bullet boundaries

**Rule** — Anchor every insertion into an edited list on a full bullet: from its `- ` line through the line before the
next `- `. After the edit, re-read the surrounding region and confirm each pre-existing bullet's text is still
contiguous under its own label.

**Why** — An insertion whose replaced span ends inside a multi-line bullet leaves that bullet's remaining sentences
attached to the new bullet. The prose stays grammatical, so it reads as intended. Link, size, and README-sync hooks
check links, bytes, and version strings, and the Step 7 drift check compares narrative against behavior. None of them
checks which bullet a sentence belongs to, so the defect lands silently and only surfaces when a later edit touches
the same region.

**Verified against source** — reproduced from history, not taken from the report. A prior fold's README diff replaced
a span ending mid-bullet: the original bullet's closing sentences stayed in the file but ended up as the tail of the
newly inserted bullet, and every hook passed on that commit. A later fold re-attached them to their original bullet.

**Coverage before this fold** — `partial`. The anchor-from-bytes rule governs where an anchor's *text* comes from, not
where its span *ends*. The range-probe uniqueness rule governs counting. Neither checks structural boundaries.

**Classification** — `principle`. It applies to any exact-match edit into structured prose (bullets, table rows,
numbered steps), not only to README sync.

**Escalation** — None. No earlier rule covered it; this is a gap, not a re-violation.

**Where** — `SKILL.md` → Step 7, a new bullet directly after "Sync README + docs" that covers every list the step
edits.

**Arithmetic** — `SKILL.md` body 10997 → 11345 B (+348), no reclaim needed; ceiling 24576.
