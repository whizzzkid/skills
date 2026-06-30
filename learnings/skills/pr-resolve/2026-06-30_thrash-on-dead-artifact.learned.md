---
skill: wk-pr-resolve
date: 2026-06-30
type: pattern
severity: medium
---

When a bot re-fires on prose inside one file across rounds, verify the file is actually consumed before iterating its wording — a dead artifact should be deleted, which ends the thrash structurally.

**What happened:** A bot kept raising fresh prose-quality findings on an orchestrator-spec doc across consecutive push rounds. Each fix reworded the doc and triggered the next finding. The loop only ended once it was established that no code, CI prompt, or runtime path ever read the doc's content — it was bundled into a context tarball but never opened. Deleting the file removed the whole class of findings at once.

**Root cause:** The thrash gate treats every re-fire as "fix the prose better." It never asks the prior question: is this file load-bearing? A file no consumer reads cannot have its findings fixed into convergence — only restructuring or deletion ends the loop.

**Suggested fix:** In the Step 4 thrash handling, when re-fires concentrate on a single non-code file, add a consumer check before the next prose fix: grep the repo for any code/CI/prompt that reads the file's content (not merely references its path or bundles it). If nothing consumes it, present delete/restructure as the first option, ahead of another wording pass.
