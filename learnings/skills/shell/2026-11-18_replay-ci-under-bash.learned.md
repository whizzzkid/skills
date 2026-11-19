---
skill: wk-shell
date: 2026-11-18
type: correction
severity: low
verified-against-source: yes
---

Replay CI shell snippets under `bash`, not the agent's login shell.

**What happened:** Replaying a workflow's `for entry in $LIST` loop directly in the Bash tool (zsh login shell) produced
a false failure: zsh does not word-split unquoted parameters, so the loop ran once over the whole string.

**Root cause:** Bash tool inherits the user's zsh; CI `run:` steps use bash. Confirmed by re-running under `bash -c`,
which produced the expected per-item output.

**Suggested fix:** When verifying a CI script claim, wrap it in `bash -c` (or a `.sh` file run with bash) and match
platform-specific tools (`stat -c` vs `stat -f`). Keep scratch files in a fixed temp dir so cleanup needs no
variable-based `rm -rf`, which the safety check blocks inside `bash -c`.
