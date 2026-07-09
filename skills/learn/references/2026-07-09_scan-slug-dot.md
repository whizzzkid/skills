---
class: principle
skill: wk-learn
date: 2026-07-09
severity: low
---

- **Rule:** Derive the scan-mode project slug by collapsing EVERY non-alphanumeric
  character to `-` (`sed 's|[^A-Za-z0-9]|-|g'`), not just `/` and `_`. Keep the
  longest-common-substring directory fallback as the safety net.
- **Why:** Claude Code normalizes any non-alphanumeric (including `.`) to `-` in
  project directory names. A transform that collapses only `/` and `_` produced a
  slug that missed the transcript directory for a cwd with a dotted segment (a
  `first.last` home dir), so the exact-match glob returned nothing and the scan
  silently reported zero transcripts.
- **Where:** Step S1 slug derivation — broadened the character class and updated
  the slug-mismatch fallback note.
