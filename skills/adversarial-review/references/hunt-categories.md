---
class: principle
---

# Hunt Categories

`category:` (Step 4) is one of — sweep catalog holds the detail:

- **Logic / arithmetic** — off-by-one, pagination edges.
- **Type coercion** — `"0"` vs `0`, canonical text vs numeric equivalence, `[]` vs `{}`.
- **State / ordering / concurrency** — use-before-init, use-after-close, async interleave, races, lock asymmetry.
- **Contract / cross-system** — signature widening, producer≠consumer layout, cleanup-before-verify.
- **Refactor-removed** — validation, recursion, error handling silently dropped.
- **Test quality** — tautology, missing assertions/failure path, asymmetric coverage.
- **Security / data loss** — injection, secret leakage, traversal, unprotected writes, missing rollback.
- **Error handling** — swallowed errors, generic catches, wrong error class.
- **Runtime / performance** — runtime-matrix gaps, quadratic scans, repeated I/O.
- **Artifact provenance** — state inferred from a produced artifact without gating on its production fidelity (degraded/partial/fallback modes void the inference).
