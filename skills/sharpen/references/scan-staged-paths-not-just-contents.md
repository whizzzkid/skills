---
class: principle
---

**Rule** — Scan staged file PATHS against `.skillprohibit`, not only file contents: `git diff --cached --name-only | grep -iEf .skillprohibit`. When a lesson is *about* a prohibited-named subject, pick a generic slug for its learning/reference filenames up front; never derive the slug from the subject.

**Why** — `check-prohibited.sh` greps added diff content and the commit message, never the staged paths. A `grep -f` content scan reads bytes inside files, not their names. A prohibited term embedded only in a filename or slug passes every existing gate yet still ships publicly.

**Where** — Step 5 mechanical/prohibited scan, alongside the staged-content scan. Deriving a slug from the subject name is the common origin of the leak — block it at distill time.
