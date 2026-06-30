---
skill: wk-adversarial-review
date: 2026-06-30
type: gap
severity: low
---

When a PR deletes a file, grep the whole repo for comments and string literals that name the deleted file — a sibling comment still referencing it is stale and compiles cleanly.

**What happened:** A PR deleted a doc file. A neighboring source file's build/codegen comment still named the deleted file ("keep the embedded {file} in sync"). The deletion compiled and tests passed, so the stale reference shipped to the diff and an automated reviewer flagged it post-push instead of the sweep catching it pre-push.

**Root cause:** The stale-term sweep (2.8) keys on renamed/removed *symbols*; a deleted *file* whose name lives only in prose comments and string literals is not a symbol, so a symbol-grep misses it. Nothing pinned the comment to the file's existence.

**Suggested fix:** Add to the 2.8 sweep: for every file deleted in the diff, grep the entire repo (comments, docstrings, string literals, not just code references) for the deleted file's basename; each surviving mention in a non-historical file is stale-reference drift to fix in the same PR.
