---
skill: wk-commit
date: 2026-06-16
type: gap
severity: medium
---

Push-rejection path should default to merge, not rebase, to avoid a required force-push.

**What happened:** When `git push` was rejected non-fast-forward (remote had new commits), the agent rebased the local commit on top of the remote, then needed a force-push — which the auto-classifier blocked, requiring manual user intervention.

**Root cause:** The skill's push-rejection guidance says "report it and ask how to proceed" but does not reference the existing global preference for merge over rebase. The agent defaulted to rebase, which rewrites history and requires force-push on an already-published branch.

**Suggested fix:** Add to the push-rejection section: when the remote has diverged, default to `git pull --no-rebase` (merge) before retrying push; only rebase when the user explicitly requests clean history, since rebase rewrites published commits and requires a force-push.
