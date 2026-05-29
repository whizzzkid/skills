---
skill: wk-pr-review
date: 2026-05-29
type: pattern
severity: medium
---

Spec docs: audit arithmetic claims and machine-local absolute paths as separate passes.

**What happened:** A design spec doc contained two independent portability bugs: (1) a count cell ("all six") that was one behind after a section was split, and (2) machine-specific absolute worktree paths (`~/gitc/$EMPLOYER/...`) committed as permanent doc references.

**Root cause:** The read-based adversarial analysis pass in Phase 3 / Phase 4 (doc-only path) doesn't enumerate a concrete checklist of stale-numeric and local-path antipatterns. Both are easy to miss when reviewing prose.

**Suggested fix:** Add two explicit adversarial passes to the doc-relocation / documentation-only Phase 4 substitute:
- **Arithmetic audit:** every numeric literal in a table or enumerated claim should be cross-checked against the actual items counted in the doc (section count, fixture floor, etc.).
- **Local-path audit:** flag any absolute path that contains a username, machine name, or worktree directory — committed specs should use repo-relative paths or drop the path entirely.
