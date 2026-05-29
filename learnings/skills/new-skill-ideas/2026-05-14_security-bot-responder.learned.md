---
skill: wk-pr-resolve
date: 2026-05-14
type: pattern
severity: low
---

Add a sub-pattern for responding to security-bot findings via their native command grammar.

**What happened:** A security bot posts findings as PR issue comments, each with a stable finding
ID (e.g. `<prefix>_<hex>`). The bot supports structured feedback commands posted as reply
issue-comments: `@<bot> <action> <FINDING_ID> <feedback>`, with actions like `fp` (false positive)
and `nit` (low-impact). The agent drafted a generic dismissal instead of the bot-native command,
leaving the finding open in the bot's tracker.

**Root cause:** wk-pr-resolve had no explicit guidance for security bots' structured command grammar.

**Suggested fix:** Add a section to wk-pr-resolve (now present as "Bot-native reply syntax") that:
1. Detects security-bot issue comments in the three-surface fetch.
2. Extracts the finding ID (generic pattern `<prefix>_<hex>`).
3. Presents options: (fp) false positive, (nit) low-impact, (s) skip.
4. Posts the reply as `@<bot> <action> <finding-id> <user_feedback>` via `/issues/{n}/comments`.
