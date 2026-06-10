---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
severity: high
---

- **Rule:** After fixing source that has a committed compiled/generated
  artifact, add a rebuild-and-re-commit step before the clear verdict.
- **Why:** A fixed source file with an un-regenerated artifact (`.wasm`,
  `go:generate`/`go:embed` target, generated code) trips a CI freshness
  check one round after clearing.
- **Where:** Sweep 2.30 (Committed-artifact freshness after source fix).
