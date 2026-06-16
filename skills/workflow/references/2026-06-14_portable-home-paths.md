---
class: principle
date: 2026-06-14
---

# Reference user-land paths via $HOME, never bare home paths

**Rule:** In skills, configs, and committed scripts, reference user-land
configuration paths via `$HOME/...` (or `${HOME}`), never a hardcoded
machine-absolute home directory (an OS user-home path literal).

**Why:** Bare home paths are non-portable — they break for any other user or
machine and leak the author's username into committed artifacts.

**Where:** Phase 2 → Code Standards, "Portable home paths" bullet.
