---
class: principle
---

# Prefer CI branch metadata for build labels

**Rule:** Derive build labels from CI-provider branch metadata before invoking
git. Reject empty values and detached `HEAD`; test with git unavailable.

**Why:** Checkout metadata can be detached or inaccessible even when the CI
provider exposes the logical branch directly.

**Where:** Mechanical sweep 2.5 for base and branch discovery.
