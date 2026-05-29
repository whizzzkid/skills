---
skill: wk-pr-merge
date: 2026-05-29
type: correction
severity: high
---

Do not exclude self-review threads from the unresolved-thread count in Step 4.

**What happened:** Step 4's GraphQL check filtered out threads whose root-comment author matched the PR author, treating them as self-review and non-blocking. GitHub's branch protection policy counts ALL unresolved threads regardless of author. The skill passed its own gate and attempted the merge; GitHub rejected it with "base branch policy prohibits the merge."

**Root cause:** The skill's exclusion logic mirrors the intent of wk-pr-resolve (don't triage your own notes as external feedback), but branch protection enforcement is stricter — it has no concept of "self-review." Any unresolved thread blocks the merge at the platform level.

**Suggested fix:** In Step 4, count ALL unresolved non-outdated threads. Do not filter by author. If any remain unresolved (including self-review threads), require the user to resolve them before proceeding — or offer to resolve the self-review threads automatically as a pre-merge cleanup step.
