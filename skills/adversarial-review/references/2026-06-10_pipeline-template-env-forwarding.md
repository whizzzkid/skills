---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
severity: high
Supersedes: the prior sweep-2.20 step-6 blanket exemption of BUILDKITE_*/GITHUB_*/CI_* prefixes
---

- **Rule:** The platform auto-injection exemption applies only to native
  steps. A `docker_compose`/container plugin forwards only vars in its
  `env:` list — an auto-injected prefix read inside the container is null
  unless explicitly listed. On a newly-added template, check every
  platform-native var the script reads (incl. baseline fallbacks) against
  the template's `env:` list.
- **Why:** A new template invoked a script with `BUILDKITE_*` fallbacks
  absent from its docker-compose `env:`, making them dead in the container;
  the blanket exemption hid the gap.
- **Where:** Sweep 2.20 (Env-var pipeline forwarding), refined step 6 + new
  step 7.
