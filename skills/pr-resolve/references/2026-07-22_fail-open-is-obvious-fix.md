---
class: principle
---

- **Rule**: When classifying a review suggestion, treat a **fail-open** defect
  (swallowed errors, silent returns) in a script that writes or publishes
  external artifacts as `obvious-fix`, absent an explicit
  idempotent-pass-through requirement.
- **Why**: A fail-open path in artifact-producing code ships broken output
  silently; there is no legitimate "skip" rationale, so it is not a
  judgment call.
- **Where**: wk-pr-resolve "Classify suggestions" table (`obvious-fix` row).
