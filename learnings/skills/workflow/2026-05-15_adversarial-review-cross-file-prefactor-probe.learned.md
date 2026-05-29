---
skill: wk-workflow
date: 2026-05-15
type: gap
severity: medium
---

Phase 4 adversarial review did not catch that `coreCheckNames` duplicated `DiscoverChecks` from `loader.go`.
The bot caught it as a Minor code-duplication finding on the next cycle.

**What happened:** `coreCheckNames` scanned `skillsDir/checks/*.md` with `os.ReadDir` + `strings.HasSuffix` —
the same operation `DiscoverChecks` (loader.go) already performs via `filepath.Glob`. The prefactor probe was
supposed to catch this (wk-workflow: "grep for the operation across the codebase"), but the grep was scoped to
the changed file (`config.go`) rather than the whole package, so `DiscoverChecks` was never surfaced.

**Root cause:** The prefactor probe instruction says "grep for the operation across the codebase" but in practice
the reviewer only grepped within the file being modified. Cross-file duplication hides in plain sight when the
search scope is too narrow.

**Suggested fix:** Strengthen the prefactor probe instruction: "When a new function performs a filesystem operation
(ReadDir, Glob, os.Stat on a path pattern), grep the **entire package** — not just the current file — for the
same path pattern or operation type before writing it. `grep -rn 'ReadDir\|filepath.Glob' <package_dir>`."
