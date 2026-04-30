---
skill: wk:self-review
date: 2026-04-30
type: gap
severity: high
---

Audit ALL stderr-emitting code paths for credential exposure when GITHUB_TOKEN is embedded in a remote URL.

**What happened:** PR #NNN fixed credential leakage in the primary `git clone` stderr path but missed three parallel code paths: the fallback `git clone`, the `git fetch` in `setup_env.sh`, and the `git fetch` in `publish.sh`. Each required a separate review round by bots. The fix pattern was identical each time — add `sed -E 's|https://[^@]+@|https://***@|g'` before echoing to build logs.

**Root cause:** Self-review checked the specific line flagged in the first bot comment but did not query "where else does this script print stderr to build logs?" before marking the finding resolved.

**Suggested fix:** When fixing a credential-in-stderr finding, immediately grep the entire file (and sibling scripts) for every pattern that prints uncaptured stderr or error output:
```
grep -n 'stderr\|2>&1\|>&2\|cat.*ERR\|echo.*err' <file>
```
Verify each hit either (a) captures stderr through the same redaction sed pipeline, or (b) cannot contain a token-bearing URL. Only close the finding after all hits are verified.
