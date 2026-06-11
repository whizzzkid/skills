---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
---

- **Rule:** Pipe `git diff "$BASE...HEAD"` directly into the subagent
  prompt; never hand-transcribe the diff inline. If an excerpt is forced by
  length, verify it against the file (duplicated lines / hunk boundaries)
  before dispatch.
- **Why:** Manual transcription introduces artifacts the subagent flags as
  false blockers, burning a fix cycle on a diff that was actually correct.
- **Where:** Step 3 subagent dispatch.
