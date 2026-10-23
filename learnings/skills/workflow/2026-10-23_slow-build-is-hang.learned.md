---
skill: wk-workflow
date: 2026-10-23
type: surprise
severity: high
verified-against-source: yes
---

A "slow" compiled-language build can be a lock deadlock; diagnose processes and environment before optimizing flags.

**What happened:** A Swift build reported as very slow had compiler frontends alive for 40+ minutes at 0% CPU. A
stack sample showed them sleeping in the module-cache lock wait while rebuilding SDK modules from textual interfaces.

**Root cause:** An exported `CPATH` in the user's shell profile pointed at a different SDK's `usr/include`. Against a
pinned SDK, implicit module builds mixed two SDKs' headers and a single frontend waited on its own module lock forever.
Confirmed by reproducing on a one-line file: hangs with `CPATH`, finishes in ~40 s without it.

**Suggested fix:** Before optimizing a slow build, list long-lived compiler processes with their CPU use and sample one
at 0% CPU. When a build pins an SDK, check inherited header/SDK env vars (`CPATH`, `C_INCLUDE_PATH`,
`OBJC_INCLUDE_PATH`, `SDKROOT`) and reproduce on a minimal input before changing compiler flags.
