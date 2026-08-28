---
skill: wk-adversarial-review
date: 2026-08-27
type: gap
severity: medium
verified-against-source: yes
---

A bash function called under `if ! fn; then` has errexit suspended for its whole body, so unguarded intermediate commands silently fall through -- the review caught this in one function but missed the identical sibling.

**What happened:** One helper carried a comment explaining that `set -e` is suspended inside a conditional context and guarded each step with `|| return 1`; a sibling extraction helper in the same library had the same call shape but no per-step guards, and the review cleared it. A later round flagged it.

**Root cause:** The sweep treated the errexit-suspension finding as file/function-local instead of sweeping every function invoked from a conditional context in the same library for the same missing `|| return 1` guards.

**Suggested fix:** When any finding involves errexit suspension in a conditional context (`if fn`, `fn ||`, `&&`), enumerate every function in the touched library that is called from a conditional and verify each intermediate command has an explicit failure guard; one instance implies siblings (same rule 2.88 already applies to gates).
