---
skill: wk-testing-skeleton
date: 2026-06-17
type: gap
severity: medium
---

In fake shell-binary scripts, `echo "$@"` placed after a shift-consuming while-loop always emits nothing.

**What happened:** A fake `curl` script was written to log API call URLs by echoing `$@` after the arg-parsing while loop. The loop consumed all positional args via `shift`, so `$@` was empty at the echo site. The log file was never written, and the tests failed with a missing-file error rather than a useful assertion failure.

**Root cause:** Bash `shift` mutates `$@` in place — once a positional arg is shifted out of `$@`, it is gone. Placing `echo "$@"` after a complete shift-consuming loop is always a no-op.

**Suggested fix:** Capture values during the loop in a named variable (e.g. `api_url="$1"` in the wildcard `case` branch), then use that variable after the loop ends. Document this pattern in the fake-binary template so authors don't reach for `$@` post-loop.
