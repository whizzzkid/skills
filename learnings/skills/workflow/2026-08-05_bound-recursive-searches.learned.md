---
skill: wk-workflow
date: 2026-08-05
type: correction
severity: medium
verified-against-source: n/a
---

Bound recursive repository searches before executing them.

**What happened:** A recursive text search traversed dependency and generated-output directories,
producing millions of irrelevant characters before it could be stopped.

**Root cause:** The command searched a broad repository subtree without restricting itself to
tracked source files or excluding dependency and build directories.

**Suggested fix:** Prefer `git grep` for tracked repository content, or explicitly exclude
dependency, distribution, coverage, and cache directories from recursive searches.
