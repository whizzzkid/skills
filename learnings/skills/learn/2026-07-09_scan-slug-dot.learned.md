---
skill: wk-learn
date: 2026-07-09
type: gap
severity: low
---

Scan-mode project-slug derivation omits `.` from the character class, so a cwd containing a dotted segment (e.g. a `first.last` home dir) yields a slug that matches no transcript directory.

**What happened:** `wk-learn scan` built the slug with `sed 's|[/_]|-|g'`; Claude Code also normalizes `.` to `-` in project dir names, so the derived path missed and the exact-match glob returned nothing.

**Root cause:** The documented slug rule only collapses `/` and `_`; the real normalization also collapses `.` (and likely other non-alphanumerics).

**Suggested fix:** Broaden the slug transform to `sed 's|[^A-Za-z0-9]|-|g'` (or add `.` to the class) in Step S1, and keep the longest-common-substring fallback as the safety net.
