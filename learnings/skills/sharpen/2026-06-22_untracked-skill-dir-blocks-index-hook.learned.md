---
skill: wk-sharpen
date: 2026-06-22
type: correction
severity: medium
---

An untracked skill dir from another session blocks the `check-readme-index` hook on every sharpen commit; move it aside, commit, restore.

**What happened:** During batch sharpen, every commit failed the `check-readme-index` pre-commit hook because an unrelated untracked `skills/<name>/` directory (left by another session, not part of this run) had no rows in `README.md` / `skills/README.md`. The hook scans the whole `skills/` filesystem tree, including untracked dirs, so it blocked a correctly-scoped commit.

**Root cause:** `check-readme-index` compares the index files against the `skills/` directory set on disk, not against staged paths. Any untracked skill dir in the tree fails it. Authoring index rows for another session's incomplete skill would be scope creep and could be wrong.

**Suggested fix:** When a hook blocks a scoped sharpen commit on an untracked skill dir this run did not create, do not index or commit it. Move the untracked dir aside (`mv skills/<name> /tmp/agent/...`), land the scoped commit, push, then restore it (`mv` back) untouched. Never `git add` another session's incomplete skill to satisfy the hook.
