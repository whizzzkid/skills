---
class: principle
---

**Rule**

Audit the full container runtime env-read set against the compose `environment:` /
plugin `env:` forwarding list before treating the config as complete — not just the
vars the diff added. Grep the whole runtime call graph (scripts + libraries) for env
reads, diff against the forwarding list, flag gaps, and cross-check sibling templates.

**Why**

Compose and the `docker_compose` plugin forward only explicitly-listed vars; agent-level
vars (CI builtins, secrets) are silently absent inside the container. A missing entry
surfaces as a no-op "feature not enabled" at runtime, not an error. Never proxy a target
SHA with a host-side build SHA — different values, fails downstream comparisons.

**Where**

`skills/docker/SKILL.md` → "Audit Runtime Env Reads Against the Forwarding List".
