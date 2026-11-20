---
class: principle
source: learnings/skills/workflow/2026-11-20_browser-verify-persistence-by-requests.learned.md
date: 2026-11-20
skill: wk-workflow
---

**Rule** — In the frontend live preview, back every restore, persistence, or caching claim with a network
request-count or window-marker assertion, not DOM text alone.

**Why** — A restored view and a re-fetched view render the same text; only request counts or a marker set before
reload distinguish them. Retrospect evidence: this check proved restore behavior that text assertions could not.

**Where** — `SKILL.md` → Phase 3.6 (Frontend Live Preview).
