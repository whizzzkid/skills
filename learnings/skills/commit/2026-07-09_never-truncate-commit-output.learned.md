---
skill: wk-commit
date: 2026-07-09
type: gap
severity: medium
---

Piping `git commit` through `| tail -N` can hide a pre-commit hook abort, making a FAILED commit read as success.

**What happened:** `git commit ... 2>&1 | tail -3` cut off the hook's `✗ pre-commit` block and the missing `[branch sha]` confirmation line. The output ended on a still-running hook glyph, which looked like completion. HEAD had not advanced and the files were still staged, but the truncated output gave no signal — only a later `git status` revealed nothing committed.

**Root cause:** `tail -N` drops the tail-end error message AND the success confirmation together, so a short truncation window is indistinguishable between "succeeded" and "hook blocked".

**Suggested fix:** Never truncate `git commit` output to so few lines that the abort/`✗`/confirmation is lost. Either show full output, or append `&& echo COMMIT-OK` / check `$?`, and always confirm HEAD advanced (`git log --oneline -1` or `git rev-parse HEAD` before/after). Treat absent `[branch sha]` confirmation as a failed commit, not a display artifact.
