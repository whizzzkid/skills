---
skill: wk-pr-review
date: 2026-05-29
type: correction
severity: high
---

Personal artifacts committed in doc PRs — local absolute paths, worktree dirs, machine-specific references — should be flagged as blocker, not suggestion.

**What happened:** Two lines in a committed spec contained machine-specific absolute paths (local worktree path under `~/gitc/$EMPLOYER/`, local data-pack path under the author's workspace). These were filed as `suggestion`-severity nits. The user indicated this should be treated as a more severe finding — personal dev environment artifacts have no place in committed repository docs.

**Root cause:** The reviewer treated local-path portability as a style concern rather than a correctness/hygiene concern. But a committed path that only resolves on one machine is broken for every other reader and reviewer, and leaks personal environment structure into a shared artifact.

**How to apply:** During Phase 3 doc adversarial scan, flag any of the following as `blocker` severity when found in committed files: absolute paths containing a username or home directory, worktree/workspace paths specific to one machine, references to uncommitted local files by absolute path, references to local tool state (local branches, local worktrees, local plan files) stated as permanent facts. The fix is always to drop the path, use a repo-relative path, or replace with a generic description.
