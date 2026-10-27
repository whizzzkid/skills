---
skill: wk-sitrep
date: 2026-10-27
type: surprise
severity: medium
verified-against-source: yes
---

Dozens of tickets showed a same-day `updated` stamp caused by someone else's bulk label edit.

**What happened:** An open-ticket sweep sorted by `updated` surfaced about thirty tickets stamped inside the closed-day window. The changelog showed a single bulk label edit by another person, not user activity.

**Root cause:** `updated` changes on any edit by anyone; the Yesterday-synthesis rules require user-authored evidence but the Jira brief did not say to check the changelog author.

**Suggested fix:** In the Jira agent brief, require changelog or comment authorship before counting a ticket as the user's work, and treat identical timestamps across many tickets as a bulk-edit signal.
