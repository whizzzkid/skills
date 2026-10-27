---
class: principle
source: learnings/skills/sitrep/2026-10-27_bulk-edit-update-stamps.learned.md
date: 2026-10-27
skill: wk-sitrep
---

**Rule** — Count a Jira ticket as the user's work only when a changelog entry or comment inside the evidence window
is authored by the user. Treat an identical `updated` stamp across many tickets as a bulk-edit signal, not activity.

**Why** — An open-ticket sweep sorted by `updated` surfaced about thirty tickets stamped inside the closed-day
window; the changelog showed one bulk label edit by someone else. `updated` moves on any edit by anyone, and the Jira
brief never asked for authorship, so the Yesterday-synthesis "user-authored evidence" requirement had nothing to
check against.

**Where** — `SKILL.md` → `start` Stage 2 Jira bullet (*Activity = user-authored change*), `end` Stage 2 Jira bullet;
`yesterday-synthesis.md` → Available-domain sweep → Jira and Confluence.
