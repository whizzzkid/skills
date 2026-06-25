---
skill: wk-sharpen
date: 2026-06-25
type: gap
severity: low
---

Batch-mode Source 3 memory diff against the distilled marker silently reported every memory as un-distilled due to a path-format mismatch.

**What happened:** Comparing the memory directory listing to `.distilled-memories` with `comm` returned all ~99 files as "not distilled". The listing carried doubled slashes (`dir//file.md` from a trailing-slash glob) while the marker stored single-slash absolute paths, so no lines matched.

**Root cause:** `comm` does exact string matching; the two path sources were not normalized to the same form before diffing. The marker is authoritative but format-fragile.

**Suggested fix:** In batch mode Source 3, normalize both sides before `comm` — collapse repeated slashes (`sed 's#//#/#g'`) and `sort -u` both the listing and the marker. Treat a result where *every* memory shows un-distilled as a probable format mismatch, not a real backlog — sanity-check before processing.
