---
class: principle
---

**Rule** — Feed the prohibited-term / overfit scan the authoritative staged set (`git diff --cached --name-only`), never a hand-built path list. Treat a NONE result as unverified until a known-positive line proves the grep actually fires.

**Why** — A manually assembled file-list silently under-matches and diverges from what the commit will carry. A trusted false-negative slips internal codenames past the scan; the `check-prohibited` hook then blocks the commit, costing a failed-commit + amend cycle. The hook is a backstop, not the first line of defense.

**Where** — Any pre-commit mechanical scan that must demonstrably exercise every file the commit includes. Drive the scan from the commit's own staged set and sanity-check a clean result.
