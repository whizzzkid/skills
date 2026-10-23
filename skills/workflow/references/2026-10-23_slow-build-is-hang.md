---
class: principle
---

# A "slow" build is a hang until its processes prove busy

**Rule** — Before optimizing a build reported as slow, prove it is working:

- List long-lived build/compiler processes with elapsed time and CPU (`ps -o pid,etime,%cpu,command`).
- Any process alive for minutes at ~0% CPU is blocked, not slow → sample its stack (`sample <pid>` on macOS,
  `gdb -p <pid>` / `eu-stack -p <pid>` on Linux) and name the wait (lock, I/O, child process).
- When the build pins an SDK or toolchain, check header/SDK variables inherited from the shell profile (`CPATH`,
  `C_INCLUDE_PATH`, `OBJC_INCLUDE_PATH`, `SDKROOT`, `DEVELOPER_DIR`). They silently override what the pin implies.
- Reproduce on a minimal input (a one-line source file) with the variable present and removed (`env -u <VAR> …`).
  Only after the build is proven busy do compiler flags, caching, or parallelism become the lever.

**Why** — Implicit module builds that pick up a second SDK's headers via an inherited include-path variable can
leave a compiler frontend waiting on its own module-cache lock forever: 40+ minutes at 0% CPU, read as "slow".
Flag tuning cannot fix a lock wait, so optimizing first burns time on the wrong axis. A stack sample of one idle
process names the wait directly; a minimal repro with and without the variable proves the cause.

**Where** — `SKILL.md` → Phase 3: Test → "a 'slow' build is a hang until its processes prove busy" bullet.
