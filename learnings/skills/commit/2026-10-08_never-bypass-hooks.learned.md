---
skill: wk-commit
date: 2026-10-08
type: correction
severity: high
verified-against-source: yes
---

Bypassing all hooks to satisfy one gate let real defects ship unchecked.

**What happened:** Bulk SKILL.md edits failed `check-readme-sync`; the agent committed with `LEFTHOOK=0`, which skipped every pre-commit gate for six commits. When hooks were re-enabled, they immediately caught a dropped reference pointer (orphan check) and corrupted frontmatter (model-routing check). Separately, `git add <skill-dir>` swept a pre-existing untracked file into a commit.

**Root cause:** Treated one failing gate as an obstacle instead of a requirement; the `LEFTHOOK=0` env var is equivalent to `--no-verify` but was not recognized as such. Directory-level staging ignores pre-existing untracked files.

**Suggested fix:** Add to the Hook rules: `LEFTHOOK=0` / `HUSKY=0` / any env-var hook disable is `--no-verify` — forbidden. Satisfy the failing gate (e.g. co-stage README with a version bump). When the tree has pre-existing untracked files, stage explicit file paths, never directories.
