---
skill: wk-workstyle-naming
date: 2026-07-10
type: correction
severity: medium
---

Name identifiers in a security/authorization gate so the eligibility intent (who counts) is self-evident, and comment the exact scope of any author-agnostic set.

**What happened:** A helper returned a set of "dismissed approval" review IDs (author-agnostic — humans and bots), consumed by a human-only re-approval gate. The user asked "will this count dismissed reviews from bots or only humans?" — the naming (`dismissed_approval_ids`) did not make the human-only intent legible, so the reader could not tell bots were filtered elsewhere.

**Root cause:** The variable named *what it recovered* (dismissed approvals) but not *its role in the gate*, and no comment flagged that human-vs-bot filtering happened at a separate site. A security gate's naming should let a reviewer confirm the eligibility rule without tracing the whole method.

**Suggested fix:** In an auth/eligibility gate, name each intermediate set for its precise scope (e.g. `originally_approved_dismissed_ids`) and add a one-line comment stating it is author-agnostic and that the human-only filter is enforced at the named downstream gate — so "who counts" is answerable at a glance.
