---
skill: wk-adversarial-review
date: 2026-08-05
type: pattern
severity: high
verified-against-source: yes
---

Task-registry migrations require a repository-wide raw-invocation sweep.

**What happened:** A migration centralized most commands but left the same raw tool invocation in
multiple sibling CI jobs and contributor help text.

**Root cause:** The initial audit focused on the changed workflow and package boundary instead of
grepping every workflow, setup instruction, and source comment for the underlying tool command.

**Suggested fix:** When a task registry becomes authoritative, grep the whole repository for the raw
implementation command and require that only the registry definition remains before clearing review.
