---
class: principle
---

# Resolve live pull-request heads for gates

**Rule:** Use stack JSON for topology and membership. Resolve each pull request's
live `headRefOid` immediately before CI or merge gating.

**Why:** Stack JSON emits a persisted local branch head even when it refreshes
pull-request association and status, so that head can lag the remote pull
request.

**Where:** `SKILL.md` → Stack topology vs live pull-request state.
