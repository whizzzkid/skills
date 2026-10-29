---
class: principle
source: learnings/skills/workflow/2026-10-29_skipped-skill-before-write.learned.md
date: 2026-10-29
severity: high
---

# Outbound writes invoke their owning skill in the same turn

**Rule** — Before any comment, reply, reaction, or message (GitHub, Jira, Slack, docs), invoke the owning skill
(`wk-gh`, `wk-jira`, `wk-slack`) plus `wk-tone` in that turn, even mid-step inside an active parent skill.

**Why** — Autonomy Rule 2 enumerated commit/PR/docs/merge/retro but not comment-shaped writes, so a "post a comment"
step inside a larger skill ran raw `gh` writes; the owning skills' footer, terseness, and voice rules never loaded. A
host attribution reminder was taken as the footer. Partial coverage → extended Rule 2 (not an escalation).

**Where** — `skills/workflow/SKILL.md` → Autonomy Rules item 2. Companion: `skills/gh` opening HARD RULE.
