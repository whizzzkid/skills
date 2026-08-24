---
skill: wk-workflow
date: 2026-08-24
type: correction
severity: high
verified-against-source: yes
---

Agent skipped Phase 2 branch pre-flight and worked against the wrong base branch

**What happened:** The skill's Phase 2 explicitly requires `git rev-parse --abbrev-ref HEAD` before the first edit, and says to resolve targets under `git rev-parse --show-toplevel` for linked worktrees. The agent ignored both instructions. It assumed `main` was the base, attempted a rebase onto `main`, hit conflicts, and instead of diagnosing the conflicts as a wrong-base signal, created a new branch off `main` and rewrote all changes against the wrong codebase (unexported functions, no test framework, no Makefile). The worktree was based on a `v5` branch with a completely different code structure — exported functions, Ginkgo tests, bats tests, Makefile.

**Root cause:** The Phase 2 branch-check pre-flight is written as an advisory step ("confirm cwd is the intended worktree") rather than a hard blocker. The agent treated it as skippable under time pressure. When rebase conflicts appeared, the agent optimized for forward progress (create a clean branch, rewrite everything) instead of stopping to diagnose why the conflicts existed. The skill's instruction was correct and sufficient — the failure was pure non-compliance, compounded by ignoring multiple secondary signals (different code structure, missing test framework, missing Makefile).

**Suggested fix:** Strengthen the Phase 2 branch pre-flight to HARD RULE status (like commit signing — "never proceed without it"). Add a corollary: "Rebase/cherry-pick conflicts are a diagnostic signal. Before any workaround (new branch, manual rewrite, abort-and-redo), run `git log --oneline -5` and verify the target base matches the worktree's actual parent. Conflicts against an unexpected base mean you are targeting the wrong branch — stop and re-examine, never force through."
