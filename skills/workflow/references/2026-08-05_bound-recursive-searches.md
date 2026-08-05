---
class: principle
---

# Bound recursive repository searches before execution

**Rule** — Prefer `git grep` for tracked content. Otherwise exclude dependency, distribution, coverage, cache, and
generated-output directories before executing a recursive search.

**Why** — An in-repo root can still traverse millions of irrelevant dependency and build-output bytes.

**Where** — Phase 2 extended code standards.
