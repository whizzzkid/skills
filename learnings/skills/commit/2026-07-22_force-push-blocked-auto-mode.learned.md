---
skill: wk-commit
date: 2026-07-22
type: correction
severity: medium
---

Force-push is blocked by the auto-mode classifier; surface it for approval.

**What happened:** After a legitimate rebase (allowed by the skill's
history-rewrite path), `git push --force-with-lease` was blocked by the auto-mode
permission classifier as a destructive operation. The push only proceeded after
the user explicitly said to continue.

**Root cause:** Auto mode treats any force-push as history-rewriting and requires
explicit confirmation, even when the rebase that produced it was already
authorized. Same class as `--amend` being blocked in auto mode.

**Suggested fix:** When a rebase/history-rewrite requires a force-push, expect the
classifier to block it and surface the exact `git push --force-with-lease`
command for one-time approval in the same response — rather than issuing it and
treating the denial as a hard stop. Note `--force-with-lease` (not `--force`) as
the safe default in the prompt.
