---
skill: wk-workflow
date: 2026-06-14
type: correction
severity: medium
---

Pre-commit relative-path guard rejects bare home paths in skill prose.

**What happened:** A debloated workflow skill used bare `$HOME/.claude/...` paths and the pre-commit relative-path hook rejected the commit.

**Root cause:** The skill preserved an operational convention literally, but the repo guard treats bare home-rooted paths as machine-local identifiers even when they are configuration guidance.

**Suggested fix:** In skill prose and docs, use `$HOME/...` or repo-relative placeholders for user-land paths, then keep the instruction semantic rather than the literal path.
