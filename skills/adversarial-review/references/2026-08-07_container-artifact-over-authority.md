---
class: principle
---

# Containers receive artifacts, not fetch authority

**Rule** — Fetch the needed artifact in the trusted host-side producer; pass
only that least-privilege artifact to a container that executes
branch-controlled code.

**Why** — Forwarding an authentication agent, cloud credential, or broad token
to fetch a single file lets untrusted container code use the same authority.

**Verify** — Confirm the producer runs before the consumer and validate their
ordering with the pipeline's pinned renderer.
