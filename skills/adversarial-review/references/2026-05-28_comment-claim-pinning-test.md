---
class: principle
date: 2026-05-28
source:
  - learnings/skills/adversarial-review/2026-05-28_json-type-contract-not-tested.md
severity: medium
---

- **Rule** — flag any always/only/never/must comment claim (especially type-coercion contracts) that has no test exercising the exact asserted condition.
- **Why** — the comment-accuracy sweep checked staleness against the implementation but not against the test suite; a true-but-unpinned invariant is a reviewer-bot flag and silently brittle to refactors.
- **Where** — extended sweep 2.4 (Comment accuracy pass) with a claim-without-pinning-test check in wk-adversarial-review.
