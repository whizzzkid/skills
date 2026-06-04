---
skill: wk-sitrep
date: 2026-06-04
type: gap
severity: high
---

`start` sub-command must generate and append a standup snippet to live.md.

**What happened:** `wk-sitrep start` completed without producing a standup snippet. The user had to explicitly request it after the fact, pointing to the `wk-goodmorning` skill for the format.

**Root cause:** The `start` sub-command's Stage 4 (Write live.md) spec does not include a standup snippet step. The `wk-goodmorning` skill has an equivalent mandatory Step 2d (standup snippet) but it was never ported to `wk-sitrep`.

**Suggested fix:** Add a Stage 4b (or final stage) to `start`: after writing live.md, append a `## 📣 Standup Snippet` section just before `## 📝 Notes`. Source mapping:
- **Yesterday** → yesterday's snapshot `## Achievements`, top 3–4 author-only PRs/wins (apply authorship filter: author/co-author/primary approving reviewer only — merging someone else's PR is not an achievement)
- **Today** → today's 🔴 ASAP items (top 3–4, deadline-first)
- **Blockers** → any item flagged BLOCKED or a dependency conflict; omit heading entirely if none

Format (must include all three emoji leads for verification):
```
## 📣 Standup Snippet

- 👈🏽 Yesterday:
   - {achievement} {bare URL}
- 👉🏽 Today:
   - {priority} {bare URL}
- ✋🏽 Blockers:
   - {blocker} {bare URL}
```

Apply the same privacy filter as `wk-goodmorning §Standup privacy filter`: drop hiring/interview/candidate items, personal HR/performance items, and anything not publicly shareable. Verify `👈🏽` and `👉🏽` appear in live.md after writing (multi-byte emoji loss check).
