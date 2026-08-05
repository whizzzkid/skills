---
skill: wk-workflow
date: 2026-08-05
type: correction
severity: high
verified-against-source: yes
---

Check for the project's development-container workflow before running tests on the host.

**What happened:** Tests were started through the host toolchain without first checking whether the
project expected validation inside a development container.

**Root cause:** The workflow followed the repository's host command documentation but omitted an
environment-selection preflight before executing tests.

**Suggested fix:** Before the first test command, inspect tracked devcontainer and container-runner
configuration; use the documented container when present, and explicitly surface the absence of a
container definition before falling back to host execution.
