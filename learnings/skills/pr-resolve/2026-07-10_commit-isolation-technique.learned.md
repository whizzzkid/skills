---
skill: wk-pr-resolve
date: 2026-07-10
type: pattern
severity: low
---

Isolating one bot finding into its own commit by temporarily editing the added lines back out, staging the rest, committing, then re-adding gives clean per-triage-unit history without interactive `git add -p`.

**What happened:** Two accepted fixes landed in the same file with interleaved lines. Rather than using `git add -p` to hunk-split them, the added lines for the second fix were temporarily removed, the file staged and committed with only the first fix's lines present, then the second fix's edit was re-applied and committed on its own.

**Root cause:** `git add -p` is fragile against interleaved changes in the same hunk (it can't cleanly split lines that sit adjacent to each other), and the skill's "one commit per triage unit" rule (Hard Rule 7) states the requirement without a mechanism for the overlapping-lines case.

**Suggested fix:** Document the temporarily-edit-out / commit / re-apply technique as the mechanism for isolating overlapping fixes into separate commits.
