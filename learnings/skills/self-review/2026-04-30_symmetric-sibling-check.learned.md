---
skill: wk-self-review
date: 2026-04-30
type: gap
severity: high
---

When fixing a bug in one script, immediately audit sibling/parallel scripts for the same bug before completing self-review.

**What happened:** PR #NNN repeatedly fixed an issue in `setup_env.sh` while the symmetric code path in `publish.sh` was left broken. Examples:
- Unconditional base-branch fetch added to `setup_env.sh` → `publish.sh` still had the conditional version until a reviewer caught it.
- GITHUB_TOKEN redaction added to `setup_env.sh` clone paths → `publish.sh` fetch left unredacted until bot caught it.

**Root cause:** Self-review focused on the file in the immediate diff context without asking "does `publish.sh` have a parallel code path that needs the same fix?"

**Suggested fix:** After applying any fix to a shell script in a multi-script pipeline, immediately identify sibling scripts by searching the directory:
```
ls $(dirname <fixed_file>)/*.sh
```
For each sibling, grep for the same pattern and verify it is either (a) already correct, (b) doesn't have the analogous code path, or (c) also needs the fix. Apply in the same commit so a single review round covers both.
