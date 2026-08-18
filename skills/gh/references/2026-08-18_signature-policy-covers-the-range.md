---
class: principle
source: learnings/skills/gh/2026-08-18_signature-block-diagnosis.md
date: 2026-08-18
severity: medium
---

## A range-scoped policy must be checked over the range, not the head

A merge was blocked with every required check green, approvals satisfied, threads
resolved, and the head commit reporting `verified: true`. Every other blocker was ruled
out one at a time before the cause surfaced: a single unsigned commit partway through
the branch, carried in by a merge from a branch that had taken an unsigned direct push.
The active ruleset enforced signing across the whole commit range being merged.

**Failure mode:** the head commit is the cheap thing to inspect and it answers a
different question than the policy asks. Checking it returns a clean, confident,
wrong result, which then removes signing from the suspect list for the rest of the
investigation. The diagnosis cost is paid in ruling out every innocent cause first.

**Guard:** when a merge is blocked and a signature requirement is active, enumerate
verification across every commit in the pull request, not the head. Generally: match
the query's scope to the policy's scope — a policy that quantifies over a range is
never answered by a point sample.

**Landed in:** `SKILL.md` green-checks `BLOCKED` checklist, alongside the existing
required-context row; remediation split into a linked reference.
