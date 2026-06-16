---
skill: wk-workflow
date: 2026-06-14
type: gap
severity: medium
---

Encode portable `$HOME/...` placeholders for user-land config paths instead of bare home paths.

**What happened:** A committed skill/config referenced a hardcoded machine-absolute home directory (an OS user-home path literal), which is non-portable and leaks the author's username.

**Root cause:** Code Standards did not state a rule for referencing user-land paths.

**Suggested fix:** In skills, configs, and committed scripts, reference user-land paths via `$HOME/...` (or `${HOME}`), never a hardcoded machine-absolute home directory (an OS user-home path literal). (Materialized from retrospect 2026-06-14_session-1.)
