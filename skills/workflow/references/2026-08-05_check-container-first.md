---
class: principle
---

# Select the project execution environment before validation

**Rule** — Inspect tracked container, devcontainer, runner, and repository instructions before the first build, lint,
or test command. Use a runnable documented project container; surface its absence before host fallback.

**Why** — A valid host command does not prove the host is the project's intended validation environment.

**Where** — Phase 3, before required validation paths.
