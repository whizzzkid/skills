---
skill: wk-adversarial-review
date: 2026-05-19
type: gap
severity: medium
---

PR body not synced after a skill/dir rename commit

**What happened:** A commit renamed a skill directory and updated all in-file references, but the PR body still referenced the old name in multiple places — test plan invocations, file table paths, and summary text. Sweep 2.10 (PR metadata sync) caught this during the adversarial review gate, before push.

**Root cause:** The PR body had multiple instances of the old skill name in the test plan (`/{repo}-init` invocations), the files-changed table, and the summary bullet. Rename commits naturally update code but leave the PR body stale because PR body edits aren't part of a file diff.

**Suggested fix:** When sweep 2.10 detects a mismatch between a renamed symbol (directory, class, function, flag) in the diff and the PR body, treat it as a blocker finding with a concrete fix-sketch: enumerate each PR body line containing the old name and the replacement text. This is mechanical and should not require the adversarial subagent — sweep 2.10 itself can grep the PR body for any string that was deleted (not just moved) in `git diff --diff-filter=D --name-only`.
