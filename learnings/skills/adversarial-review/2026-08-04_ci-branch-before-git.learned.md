---
skill: wk-adversarial-review
date: 2026-08-04
type: pattern
severity: high
verified-against-source: yes
---

Prefer CI branch metadata before invoking git for build labels.

**What happened:** A build step derived a development label by invoking git, which failed under a container ownership check and would return `HEAD` in a detached checkout.

**Root cause:** CI already supplied the logical branch through provider environment variables, but the build path consulted checkout metadata first.

**Suggested fix:** Add a review sweep for build-time branch discovery that prefers provider branch variables, rejects detached `HEAD`, and tests a successful build with git unavailable.
