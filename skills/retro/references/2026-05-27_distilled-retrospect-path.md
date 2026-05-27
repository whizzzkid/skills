---
class: principle
date: 2026-05-27
severity: medium
---

- **Rule:** Retro entries go to `$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>.md` with distilled principles only — no narrative, no employer/internal-project tokens; validated by grep against `$EMPLOYER`/`$GITHUB_ORG` resolved values before write.
- **Why:** Retrospect logs are skill-improvement artifacts; narrative leaks employer-identifiable context and bloats the sharpen pipeline's signal.
- **Where:** Step 3 — new destination HARD RULE, distilled-only HARD RULE, no-employer HARD RULE, and validation gate.
