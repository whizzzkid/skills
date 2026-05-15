---
skill: wk-pr-resolve
date: 2026-05-14
type: pattern
severity: low
---

Create a skill (or wk-pr-resolve sub-pattern) for responding to a security bot bot findings.

**What happened:** a security bot bot (`{bot}`) posts security findings as issue
comments on PRs. Findings include a unique ID (e.g., `<finding-id>`). The bot supports structured
feedback commands posted as reply issue-comments in the format:
  `@<bot> <action> <FINDING_ID> <feedback>`

Actions:
- `fp` — mark as false positive
- `nit` — mark as low-impact / nitpick

Example: `@<bot> fp <finding-id> this runs in a sandbox with very limited access`

**Root cause:** wk-pr-resolve has no explicit guidance for a security bot's structured command
format, so the agent would draft a generic dismissal reply instead of the bot-native command.

**Suggested fix:** Create a `wk-<bot>` skill (or add a section to wk-pr-resolve) that:
1. Detects `{bot}` issue comments in the three-surface fetch
2. Extracts finding IDs (pattern: `drs_[a-f0-9]{8}`)
3. Presents options: (fp) false positive, (nit) low-impact, (s) skip
4. Posts reply as `@<bot> <action> <finding_id> <user_feedback>`
5. Notes: replies go to `/issues/{n}/comments` (not inline review comment replies)
