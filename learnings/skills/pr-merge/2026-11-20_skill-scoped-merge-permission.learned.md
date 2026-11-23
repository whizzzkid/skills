---
skill: wk-pr-merge
date: 2026-11-20
type: gap
severity: medium
verified-against-source: yes
---

The skill's permission guidance offers only a global `Bash(gh pr merge:*)` allow rule, which users who want merge
permission tied to the skill reject.

**What happened:** In auto mode the classifier denied a bot-only-approved merge as "Merge Without Review". The skill
pointed the user to a global allow rule. The user wanted the permission to exist only through the skill, and had
assumed `allowed-tools: Bash` already gave it.

**Root cause:** The skill frontmatter's `allowed-tools` only suppresses permission prompts; the auto-mode classifier
is a separate layer. The Step 6 permission preflight offers no skill-scoped mechanism.

**Suggested fix:** In Step 6, explain that `allowed-tools` does not override the classifier. Offer a skill-gated
PreToolUse hook (a marker written after the checklist passes, checked against the current head SHA) alongside the
global rule, and never present the global rule as the only fix.
