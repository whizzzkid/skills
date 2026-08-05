---
class: principle
---

# Verify privilege additions as target-specific contracts

**Rule** — Trace a privileged call from producer to generated target artifact. Compare sibling targets and require an
exact negative assertion that unaffected targets omit the grant.

**Why** — A privilege name alone cannot prove that a grant is necessary or narrowly scoped.

**Where** — Specialized allowlist and privilege checks.
