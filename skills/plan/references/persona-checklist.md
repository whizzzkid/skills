# Persona checklist (Step 2)

Ask each question; a missing answer is a missing plan step.

## Implementor / Reviewer

- Smallest change set? Correct order to keep tests green at each step?
- Edge cases to flag? Blast radius if wrong?
- All side effects (DB, cache, queue, downstream) addressed?
- Behavior preservation provable by tests?

## Security / Ops

- Auth, authorization, input validation, data exposure affected?
- Injection vectors, credential leaks, TOCTOU windows?
- Migration, schema change, deploy ordering? Forward-compatible? Rollback safe?
- Observability covered? Proposed operations violate documented perf constraints? Use existing mitigation pattern
  (cache, background job, materialized view).

## Product

- Delivers stated requirement, or a technically-correct different thing?
- User-visible gaps between planned and asked?
