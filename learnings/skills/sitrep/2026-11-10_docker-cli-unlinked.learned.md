---
skill: wk-sitrep
date: 2026-11-10
type: gap
severity: medium
verified-against-source: yes
---

Bootstrap probe reads a missing docker CLI as "runtime down", and the colima restart then fails.

**What happened:** `docker info` failed, so the bootstrap classified the runtime as down and invoked the colima start
flow. Colima refused to start because the `docker` binary was not on PATH: the package was installed but unlinked
(a stale completion package owned conflicting symlinks). `docker` was absent from every bin dir.

**Root cause:** the probe never separated "CLI absent" from "daemon unreachable". Both exit non-zero.

**Suggested fix:** in `bootstrap.md`, run `command -v docker` before `docker info`. Absent → report a CLI install/link
gap (check `brew list docker`, then `brew link --overwrite --dry-run docker` and confirm only completion files are
replaced) rather than starting the runtime. Also: gather agents must be told that shell commands may need the user's
profile sourced, and a truncated agent report is fixed by one targeted resend request naming the missing sections.
