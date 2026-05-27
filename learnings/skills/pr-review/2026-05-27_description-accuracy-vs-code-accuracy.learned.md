---
skill: wk-pr-review
date: 2026-05-27
type: pattern
severity: low
---

PR description/commit message accuracy is a distinct review surface from code accuracy.

**What happened:** Reviewed a clean refactor PR where all 8 code changes were correct, but the PR description contained two factual errors: (1) a line-range cited as "6–8" that was actually [6, 18], and (2) a blanket framing ("add aria-label + autoComplete on each fixture") that didn't match one fixture's intentional omission. The code itself was fine; the description would mislead future spelunkers.

**Root cause:** Phase 3 investigation focused on code correctness and stopped once confirmed. Description accuracy is a separate axis that deserves a dedicated pass — especially when the description makes specific, verifiable claims (line numbers, attribute lists, rationale).

**Suggested fix:** Add a Phase 3 step: for any PR description that cites specific line numbers, file paths, or mechanism claims, verify each claim against the actual files/diff and flag discrepancies as `suggestion`-severity body notes even when the code is correct.
