---
class: principle
date: 2026-05-28
source: ~/.claude/memory/feedback_autosync_no_confirm.md
severity: medium
---

- **Rule:** Auto-sync any dependent artifact (PR body, self-review, ticket, docs) drifted from the current branch state in the same turn — never ask "want me to update X?" for obvious drift.
- **Why:** Asking permission to fix obvious drift wastes a turn and surfaces decision fatigue for a non-decision; confirm only when the content of the sync is ambiguous.
- **Where:** Phase 5 → Post-push sync (HARD RULE: Auto-sync drifted artifacts — never ask permission).
