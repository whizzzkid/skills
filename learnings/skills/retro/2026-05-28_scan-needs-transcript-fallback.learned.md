---
skill: wk-retro
date: 2026-05-28
type: gap
severity: low
---

wk-learn scan could not extract user messages from today's transcripts because the jsonl format uses `last-prompt` / `permission-mode` / `file-history-snapshot` types, not `user` / `assistant`. The scan returned zero interruptions despite a session with six explicit user corrections.

**Root cause:** Step S1 uses `jq 'select(.type == "user" or .type == "assistant")'` which matches an older transcript schema. Current Claude Code transcripts use a different type taxonomy.

**Suggested fix:** Add a fallback to Step S1 that also tries `.type == "last-prompt"` and any message that has a `.prompt` or `.message` field. When zero user-type messages are found, warn that the transcript schema may be unrecognised rather than silently reporting zero interruptions. The retro should then fall back to git-log + commit-message reconstruction (which is reliable).
