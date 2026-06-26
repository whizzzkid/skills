---
skill: wk-pr
date: 2026-06-26
type: correction
severity: high
---

the pre-push review binary binary was not run locally before pushing, despite memory note requiring it.

**What happened:** The agent pushed commits without running `$HOME/.local/bin/<review-binary> local --quiet --repo-path .` first. The user had to explicitly ask whether the binary had been run. The binary is required before every push to catch findings before CI does.

**Root cause:** The requirement lives in a memory file but was not wired into the pre-push gate in `wk-pr`'s adversarial-review step. Memory notes are context-pressure-sensitive; a mandatory step in the skill body always executes.

**Suggested fix:** Add "run the pre-push review binary binary locally" as an explicit numbered step in `wk-pr`'s adversarial-review gate (Step 2), alongside the other repo-local static-analysis sweeps, so it cannot be skipped under context pressure.
