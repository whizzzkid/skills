---
skill: wk-workflow
date: 2026-07-31
type: correction
severity: medium
verified-against-source: n/a
---

Confirm cross-repository scope before implementing optional hardening or
installing host tooling.

**What happened:** The agent completed the required application fix, then
inferred an independent infrastructure-policy change, installed its toolchain,
and began deep validation before the user redirected the work to a containerized
development environment.

**Root cause:** The workflow treated a related source-of-truth improvement as an
implied deliverable and selected host setup without first confirming the extra
repository was in scope or checking whether a devcontainer should own the
environment.

**Suggested fix:** Separate required fixes from optional cross-repository
hardening in the plan, require user selection before implementing the latter,
and prefer a repository devcontainer before installing task-specific host
packages.
