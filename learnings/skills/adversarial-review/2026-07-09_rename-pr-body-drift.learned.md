---
skill: wk-adversarial-review
date: 2026-07-09
type: pattern
severity: medium
---

A config-key/symbol rename synced across source + tests still left the PR body pointing at the old names — the code-only grep passes while the outward-facing description lies.

**What happened:** A rename of two config keys was applied to the module constants, all spec stubs, and docs, and a repo-wide grep for the old literals returned clean. The PR body, however, still listed the old key names in three places (prose, a provisioning snippet, the stack narrative) plus a now-stale test count (`11` vs the actual `13`). Only sweep 2.10 (PR-body drift) caught it; the code sweep 2.8 had already gone green.

**Root cause:** Sweep 2.8 (rename-sync) greps the working tree, not the PR body. The PR body is a separate surface that the code grep never touches, so a rename looks "fully synced" while the description drifts.

**Suggested fix:** On any rename diff, treat the PR body as a first-class grep target: after 2.8 passes, fetch the body and grep it for every old literal AND for any hard-coded count/enumeration the diff changed (test totals, example counts, key lists). Fix body drift via `gh pr edit` — body-only, no commit, existing clearance stays valid.
