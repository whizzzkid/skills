---
class: principle
---

# Preserve the pull request's repository identity

**Rule** — Resolve `{owner}/{repo}` from the target pull request and reuse it for every scoped read, mutation,
merge, branch deletion, and verification. Use ambient organization scope only for discovery.

**Why** — A configured organization or current remote can target another repository.

**Where** — Step 1's explicit-identity hard rule and every later scoped command.

The governing hard rule landed after the incident, so it could not steer that run; no re-violation escalation applies.
