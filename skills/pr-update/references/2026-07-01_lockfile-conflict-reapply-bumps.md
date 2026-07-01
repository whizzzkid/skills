---
class: principle
---

**Rule:** Resolving a lockfile conflict during base advance (`Gemfile.lock`,
`package-lock.json`, `Cargo.lock`, …): keep the branch's structural changes
(remotes, added/removed deps, source migration) and re-apply only the base's
dependency version bumps onto it — never take one whole side. A real install
from the resolved manifest is authoritative over a clean-looking textual merge.

**Why:** Taking either whole side drops one commit's intent — the branch's
structural migration or the base's security/version bumps. Lockfiles are
generated artifacts; a textual merge can look clean yet fail to install or
resolve to inconsistent versions.

**Where:** wk-pr-update Stage 4 (Conflict resolution loop, step 2).
