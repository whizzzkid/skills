---
skill: wk-adversarial-review
date: 2026-06-25
type: pattern
severity: medium
---

Structural pre-condition analysis prevents false "missing guard" blockers.

**What happened:** A bot flagged an empty-string guard on a field (`CommitSHA`) passed into a pipeline call as a logic-error/missing-safety-net blocker. The field's upstream function (`synthesizeContext`) errors on failure — it never returns with an empty value — making the guard dead code by construction.

**Root cause:** The review evaluated the call site in isolation without tracing the full caller path. A guard that looks optional at the call site may be structurally unreachable if all code paths that reach it guarantee the field is populated.

**Suggested fix:** Add a step to the adversarial-review sweep (2.3 — dead guard reachability) that traces every code path to the call site before classifying a nil/empty guard as dead. An error-return path that prevents an empty value from reaching the call site is structural evidence, not an assumption. Specifically: if a function errors on the very failure that would produce the sentinel value, the guard is provably unreachable — classify as `suggestion`, not `blocker`.
