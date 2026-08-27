---
skill: wk-workflow
date: 2026-08-27
type: correction
severity: low
verified-against-source: yes
---

Fetch a concrete linked artifact before dispatching parallel research.

**What happened:** Parallel investigation started before the linked review comment was fetched.

**Root cause:** The artifact-first ordering in the planning workflow was not followed.

**Suggested fix:** Read the exact linked artifact first; dispatch additional research only after it is exhausted.
