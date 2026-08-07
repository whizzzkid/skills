---
skill: wk-adversarial-review
date: 2026-08-07
type: pattern
severity: high
verified-against-source: yes
---

Transfer the required artifact across a container boundary instead of forwarding a general authentication agent.

**What happened:** A CI rehearsal needed one repository file, but its first implementation mounted the checkout SSH agent into a container that executed branch-controlled code.

**Root cause:** Credential plumbing was treated as a prerequisite of the file fetch instead of separating the trusted host-side fetch from the untrusted container-side consumer. The pipeline and plugin lifecycle were rendered and driven to confirm that an artifact download runs before the container command hook.

**Suggested fix:** Add an adversarial sweep for CI container changes: when an agent socket, cloud credential, or broad token is forwarded only to obtain a file, require a host-side producer step and pass the least-privilege artifact to the container. Verify dependency and plugin hook order with the pipeline's pinned renderer.
