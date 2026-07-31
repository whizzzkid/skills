---
skill: wk-adversarial-review
date: 2026-07-31
type: pattern
severity: medium
verified-against-source: yes
---

Reserve-then-close port selection needs bounded process-level recovery.

**What happened:** A browser harness asked the operating system for a free port, closed the
listener, and launched another process with that number without recovery if the port was claimed
during the handoff.

**Root cause:** Connection polling handled slow startup but could not make the launched process
bind a different port after a collision.

**Suggested fix:** Flag every reserve-close-bind sequence as a race. Validate the expected protocol
greeting, terminate the failed process, and retry with a freshly reserved port under a small
explicit attempt bound.
