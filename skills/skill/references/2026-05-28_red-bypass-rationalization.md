---
class: principle
date: 2026-05-28
source:
  - $WK_SKILLS_HOME/learnings/skills/skill/2026-05-28_behavior-before-red.md
severity: high
---

- **Rule** — length / detail in the user's description does NOT authorize skipping the RED phase; the scaffold ships skeleton-only.
- **Why** — a rich description is the spec for the eventual GREEN body, not a measurement of baseline agent behavior; RED tests what an unaided subagent does and where it fails, which is what the skill body must counter. Skipping RED makes the body fight the imagined gap, not the actual one.
- **Where** — wk-skill Step 6 HARD RULE: added a sub-rule about description-length rationalization, mandated `<!-- DESIGN NOTES: ... -->` HTML comments for supplied detail, and required every Step heading in a fresh scaffold to ship with a `<!-- RED phase not yet run — fill in after testing baseline behavior -->` marker.
