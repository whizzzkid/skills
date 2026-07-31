---
skill: wk-sharpen
date: 2026-07-31
type: gap
severity: medium
verified-against-source: yes
---

Normalize legacy learning filenames before marking them processed.

**What happened:** Appending `.learned.md` to a queued learning preserved its
legacy date-to-slug separator, so the learning-filename hook blocked the commit.

**Root cause:** The processed-state rename assumes every queued basename already
matches the current filename convention, while the queue can contain older
names accepted before that convention existed.

**Suggested fix:** Before the processed rename, derive and validate a canonical
`YYYY-MM-DD_<kebab-slug>.learned.md` destination. Treat a collision or an
unparseable source name as a stuck item instead of staging a hook-invalid path.
