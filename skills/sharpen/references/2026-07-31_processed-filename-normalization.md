---
class: principle
---

# Canonicalize processed learning filenames

**Rule** — Build every processed learning archive as
`YYYY-MM-DD_<kebab>.learned.md`; never append the processed suffix to an
unvalidated legacy basename. Leave parse failures and collisions queued.

**Why** — Queues can retain files created under an older naming convention.
Blind suffixing preserves that stale shape, so the filename gate blocks the
otherwise-complete fold at commit time.

**Where** — `SKILL.md` → Step 7 processed-name rule and Batch Mode Source 2.
