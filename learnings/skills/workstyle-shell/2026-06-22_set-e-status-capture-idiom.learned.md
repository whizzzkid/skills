---
skill: wk-workstyle-shell
date: 2026-06-22
type: correction
severity: medium
---

With `set -e`, `cmd; status=$?` exits on non-zero before the status assignment; use `cmd || status=$?` instead.

**What happened:** A function called a helper that returns 2 for a "tolerated skip" condition. The caller used `http_code=$(helper ...); put_status=$?` — with `set -e` active, the semicolon does not suppress `errexit`, so the script exited with status 2 before `put_status` was ever assigned. The test showed `exitstatus: 2` instead of the expected `0`.

**Root cause:** Under `set -e`, any simple command that exits non-zero causes immediate script exit — the `;` separator does not suppress this. The assignment `put_status=$?` is a separate command that never runs. The `||` operator does suppress `errexit` on its left operand.

**Suggested fix:** Always use `cmd || status=$?` (initialize `status=0` before the line) when you need to capture a non-zero exit code without triggering `set -e`. Never use `cmd; status=$?` for commands that can legitimately return non-zero. In review, flag any `cmd; status=$?` pattern in scripts with `set -e`.
