---
skill: wk-buildkite
date: 2026-08-26
type: correction
severity: medium
verified-against-source: n/a
---

CI failures on a behind-base branch are not infra flakes — sync first

**What happened:** Two consecutive CI builds failed with a render-step timeout
(`:toolbox:` timed_out, exit 143). The agent diagnosed this as an infra flake
(Ruby `Open3` race condition) and recommended waiting/rebuilding. The user
corrected: the branch was behind `main`, they merged main in, and the next build
passed. The agent spent multiple rounds of API introspection and rebuild attempts
instead of checking whether the branch was current.

**Root cause:** The diagnosis focused on the error's symptom (stream-closed
exception) without checking the simplest structural cause — a stale base branch.
The agent's Buildkite log analysis was technically correct about the proximate
failure mechanism, but missed the actual fix.

**Suggested fix:** Before diagnosing a CI failure as infra, check `git rev-list
--count origin/main..HEAD` (or the PR's behind-count via `gh pr view --json
behindBy`). If the branch is behind main, recommend syncing before
rebuilding — a stale base is more likely to cause build failures than a transient
infra issue.
