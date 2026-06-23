---
skill: wk-docker
date: 2026-06-23
type: surprise
severity: medium
---

`docker` binary may be missing from PATH on macOS even after install, requiring `brew link docker`.

**What happened:** `docker` returned "command not found" in a Bash tool session despite Docker being installed via Homebrew. The symlink at `/opt/homebrew/bin/docker` was missing.

**Root cause:** Homebrew sometimes loses symlinks after package upgrades, leaving the binary in the Cellar but unlinking it from the bin directory. Bash tool sessions may also not inherit the user's full PATH.

**Suggested fix:** When `docker` is not on PATH, run `brew link docker` before any retry. Also ensure `/opt/homebrew/bin` is prepended to `PATH` in Bash tool invocations on macOS: `PATH="/opt/homebrew/bin:$PATH"`.
