---
skill: wk-sitrep
date: 2026-06-04
type: gap
severity: medium
---

`start` and `end` must explicitly commit and push after writing live.md / snapshot.md — not rely on project CLAUDE.md.

**What happened:** After Stage 4 (write live.md) and Stage 5 (write snapshot.md), the skill had no explicit commit/push step. The files were committed and pushed only because the project-level CLAUDE.md happened to contain "always commit and push after writing sitrep files." In a repo without that rule, or if the skill is run in a different context, the output would stay uncommitted.

**Root cause:** The skill spec ends at "open in browser" with no git step. Relying on ambient project instructions makes the skill non-self-contained.

**Suggested fix:** Add an explicit final stage to both `start` and `end` sub-commands, after the browser-open step:

```
Stage N: Commit and push
  git add "$LIVE_FILE"                          # start: live.md only
  git add "$LIVE_FILE" "$SNAPSHOT_FILE"         # end: both files
  git commit -m "chore(sitrep): <emoji> <sub-command> <TODAY> — <N> items, <M> meetings"
  git push
```

Commit message convention:
- `start`: `chore(sitrep): 📋 start <YYYY-MM-DD> — <N> items, <M> meetings`
- `end`:   `chore(sitrep): 📸 end <YYYY-MM-DD> — <N> done, <M> carried forward`
- Auto-actions (Jira transitions, etc.): inline in the same commit or a follow-up `chore(sitrep): ✅ <action>`

This step is unconditional — same as the browser-open step. Do not prompt the user.
