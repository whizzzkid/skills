---
skill: wk-sharpen
date: 2026-06-26
type: gap
severity: low
---

Batch mode should re-scan inboxes after each fold-commit, not only once at start.

**What happened:** Initial batch scan found 2 learnings. While folding and pushing them, a concurrent session dropped new unprocessed files into `learnings/skills/` and `learnings/retrospect/`. Each `git status` after a push surfaced fresh items (a high-sev workflow learning, then a pr-merge learning + a retrospect), requiring ad-hoc re-scans to drain them.

**Root cause:** The batch-mode scan is described as a one-shot Source 1-4 sweep at invocation. It does not prescribe re-scanning after each commit, but other sessions write learnings/retros to the same tree continuously, so a single up-front scan under-counts.

**Suggested fix:** After each fold-commit-push cycle in batch mode, re-run the Source 2/4 `find ... ! -name '*.learned.md'` scan before declaring the inbox drained. Treat "inbox empty" as a terminal check run after the last commit, not a fact established once at start.
