---
skill: wk-adversarial-review
date: 2026-06-16
type: gap
severity: high
---

Add an explicit env-forwarding sweep (sweep 2.20 extension) for docker-compose files and container-step pipeline templates.

**What happened:** A pipeline template diff that forwarded new env vars to a Docker container was reviewed without checking whether the forwarding set was complete. A sibling template already had some of the vars; the newer template was missing four. The gap was caught by tracing the runtime read set manually, not by the mechanical sweep.

**Root cause:** Sweep 2.20 ("New env reads in application code → verify forwarding in pipeline steps") focused on net-new env reads introduced by the diff. It did not prompt a full audit of all env reads in the invoked runtime path against the forwarding list — only the delta was checked. Pre-existing reads in libraries called by the changed script were missed.

**Suggested fix:** Extend sweep 2.20 with a full-path audit trigger: when the diff touches a docker-compose `environment:` block or a plugin `env:` array, grep every script and library in the container's runtime call graph for env reads and diff that set against the forwarding list. Also run a sibling-template consistency check — other templates serving the same role should forward the same logical set of vars. Surface any read without a corresponding forwarding entry as a blocker.
