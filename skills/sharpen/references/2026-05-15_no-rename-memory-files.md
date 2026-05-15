---
class: principle
---

- **Rule:** Never rename files under `~/.claude/memory/`. The `.learned.md` suffix is a Source 2 (repo learnings) convention only. Memory files keep their original `.md` name; processed state is tracked exclusively in `.distilled-sources.log`.
- **Why:** Renaming a memory file breaks `MEMORY.md` index links and orphans the content from cross-session recall. Symptom: 8 files showed up as "unprocessed" on the next scan because their basenames no longer matched the log entries, and the index pointed to dead paths.
- **Where:** Batch Mode → Source 3 → new HARD RULE adjacent to the type-feedback filter.
