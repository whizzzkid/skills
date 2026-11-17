---
skill: wk-pr-review
date: 2026-11-16
type: gap
severity: low
verified-against-source: n/a
---

Approve path with an unchanged own pending draft has no shortcut; delete+recreate is overkill.

**What happened:** A light approve run found the user's own pending draft (footered, same head SHA) whose only comment re-verified as still valid. The run submitted that draft as APPROVE via the reviews/{id}/events endpoint instead of deleting and recreating it.

**Root cause:** Phase 2/5 mandate delete+recreate for any own pending draft, but don't cover the no-delta case where the draft already equals the intended payload.

**Suggested fix:** In Phase 5, when the draft's commit_id equals PR_HEAD and the re-verified comment set is unchanged, skip the destructive DELETE and submit the existing draft (APPROVE if gate passes, else leave pending).
