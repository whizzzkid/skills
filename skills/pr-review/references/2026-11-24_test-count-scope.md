---
class: principle
source: learnings/skills/pr-review/2026-11-24_test-count-scope.learned.md
date: 2026-11-24
severity: low
---

## Count every test file in a claim's scope before refuting it

- **Rule:** A "full suite: N tests" claim may span several test directories. Before marking a test-count claim
  Refuted, enumerate every test file under the claimed scope and count across all of them; a shortfall on a partial
  run is not a refutation.
- **Why:** Replaying a claimed count by running one test directory undercounted. A second directory held the rest, and
  the sum matched the claim exactly.
- **Where:** `SKILL.md` Phase 1, empirical-claims bullet.
