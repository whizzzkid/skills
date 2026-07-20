---
class: principle
---

**Rule:** When polling CI green via `statusCheckRollup`, require the CI
provider's checks to be present in the rollup before declaring green. An empty
`statusCheckRollup` is vacuously green (`[...] | unique` on an empty array
yields no red), which reads as premature all-green.

**Why:** Right after a push the provider may not have registered its build yet,
so the rollup is momentarily empty; treating absence-of-red as green ships an
unverified commit.

**Where:** wk-pr, Step 5 CI-poll HARD RULE.
