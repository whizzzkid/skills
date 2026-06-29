---
skill: wk-sharpen
date: 2026-06-29
type: gap
severity: medium
---

A prohibited term can leak through a staged file's PATH even when its CONTENT scan is clean

**What happened:** A learning about a prohibited-named tool was distilled into generic skill text (clean). The source learning was anonymized in its body and renamed to `.learned.md`, and a principle reference was written. The content scan (`grep -iEnf .skillprohibit $(git diff --cached --name-only)`) returned NONE — but the prohibited term still survived verbatim in two committed FILENAMES (the learning slug and the reference filename).

**Root cause:** `check-prohibited.sh` scans added diff *content* lines and the commit message, never the staged paths. The Step 5 scrub guidance greps file *contents* with `grep -f`, which reads bytes inside files, not their names. A term embedded only in a slug/filename passes every existing gate yet still ships publicly.

**Suggested fix:** In the overfit/prohibited scan, also grep the staged path list itself against `.skillprohibit`, e.g. `git diff --cached --name-only | grep -iEf .skillprohibit`. When the lesson is *about* a prohibited-named subject, pick a generic slug for the learning and reference filenames up front — never derive the slug from the subject name.
