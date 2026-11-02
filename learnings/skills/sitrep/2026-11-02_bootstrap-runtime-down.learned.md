---
skill: wk-sitrep
date: 2026-11-02
type: gap
severity: low
verified-against-source: yes
---

Bootstrap's SilverBullet probe cannot tell "container runtime stopped" from "not served".

**What happened:** The probe runs `docker ps` and, on any failure (daemon unreachable), falls through to the branch that
tests for a local `silverbullet` binary. With the runtime stopped and only a compose deployment configured, the run
would report "not installed" instead of starting the runtime and the compose service.

**Root cause:** The probe conflates a non-zero `docker ps` exit (daemon down) with an empty container list. Read from
the bootstrap recipe; confirmed by the stopped runtime at the start of this run.

**Suggested fix:** On `docker ps` failure, invoke the container-runtime skill to start the runtime, then run
`docker compose up -d` in the repo that holds the compose file, and probe the served page with an HTTP request before
falling back to the local binary.
