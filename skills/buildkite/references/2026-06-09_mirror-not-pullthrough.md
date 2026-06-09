---
class: principle
skill: wk-buildkite
date: 2026-06-09
severity: medium
---

- **Rule:** Verify the exact repository exists under an internal registry
  mirror before pinning a CI step to it; do not assume working `library/*`
  images prove a pull-through cache.
- **Why:** A pre-seeded (non-pull-through) mirror fails at `docker pull` with
  "repository does not exist in the registry" for any un-seeded path.
- **Where:** "Pinning a CI step to a mirrored image" section.
