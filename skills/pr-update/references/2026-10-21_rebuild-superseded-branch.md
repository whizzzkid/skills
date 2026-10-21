---
class: principle
date: 2026-10-21
severity: low
---

# Rebuild a superseded branch from base; re-apply only the missing slice

- **Rule:** When the base already replaced most of a branch's code, rebuild from the new base and re-apply only the
  slice the base still lacks. List each superseded hunk you drop before pushing.
- **Why:** Patch-replay and rebase both carry the full net diff. On code the base already rewrote, every hunk
  conflicts, and resolving them re-does work that already landed. Rebuilding keeps the integration diff to what is
  still missing. Listing the dropped hunks keeps the never-drop-commits rule intact.
- **Where:** `SKILL.md` → Stage 3c (Patch-replay strategy).
- **Source:** a session retrospect ("What worked"). This was a positive practice with no prior rule, so it was folded
  at baseline prose with no escalation.
