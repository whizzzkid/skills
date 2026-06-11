---
skill: wk-pr-resolve
date: 2026-06-10
type: correction
severity: high
---

Bash `-f` on a dangling symlink returns false — symlink-escape tests must point to an existing file.

**What happened:** A bats test for symlink-escape rejection used `ln -s /etc/hostname target-repo/.exports/file` as the escape attempt. On macOS, `/etc/hostname` is absent, so `[[ -f "$src" ]]` returned false and the "No file found" branch fired instead of the `_under_target_root` guard. The test exited 0 (both branches do), making it silently vacuous.

**Root cause:** `-f` in bash follows symlinks and checks whether the *resolved target* is a regular file. A dangling symlink (target does not exist) returns false from `-f`, bypassing the security-guard branch entirely.

**Suggested fix:** Symlink-escape bats tests must always point to a file that is guaranteed to exist on the test OS. Use `/etc/passwd` (present on macOS and Linux) rather than files that may be absent. Mirror the pattern already used in sibling security tests in the same file.
