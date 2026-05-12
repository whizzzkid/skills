**Rule:** After writing standup output, `grep` for `👈🏽` / `👉🏽` / `✋🏽` in the written file; re-write and re-verify if any are absent.

**Why:** Bash heredoc can silently strip multi-byte emoji under certain locale/encoding settings, producing plain `- Yesterday:` / `- Today:` / `- Blockers:` instead of the required emoji-prefixed bullets.

**Where:** `### 2d. Standup snippet` (Stage 2)
