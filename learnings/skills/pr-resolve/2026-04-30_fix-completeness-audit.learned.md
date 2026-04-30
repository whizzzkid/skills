---
skill: wk:pr-resolve
date: 2026-04-30
type: gap
severity: high
---

After applying a security fix to one code path, audit all other code paths in the same PR for the same vulnerability class before marking the finding resolved.

**What happened:** PR #NNN had GITHUB_TOKEN credential exposure in stderr. The fix was applied iteratively — primary clone first, then the fallback clone, then publish.sh's fetch — each triggered by a separate bot review round, each requiring a separate response commit. The same pattern (`sed -E 's|https://[^@]+@|https://***@|g'`) was applied three times across two files with a one-day lag between each round.

**Root cause:** Each bot finding was resolved in isolation: fix the flagged line, reply with commit SHA, resolve thread. No audit was performed for other code paths with the same vulnerability class in the same PR.

**Suggested fix:** When resolving a `secrets-handling` or credential-exposure finding, before committing, grep the entire PR diff for the vulnerability pattern:
```
# Find all git operations that might print a token-bearing URL to stderr
git diff origin/main...HEAD -- '*.sh' | grep -E '(git clone|git fetch|git remote)' | grep -v 'redact\|sed.*@'
```
Apply the fix to all matching paths in one commit. The response comment should list every path fixed: "Applied to primary clone (L224), fallback clone (L231), and publish.sh fetch (L184)." This prevents the bot from finding the same vulnerability class in the next review cycle.

More generally: when resolving any finding in vulnerability class X, scan the full diff for all code that could share the same flaw. One commit, one reply, all instances.
