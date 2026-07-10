---
date: 2026-07-10
slug: commit-isolation-technique
---

- **Rule:** When two accepted fixes land in the same file with interleaved
  lines, isolate them without interactive staging: edit the *other* fix's
  lines back out temporarily, stage/commit the file with only the current
  fix's lines present, then re-apply the other fix's edit and commit it
  separately.
- **Why:** `git add -p` is fragile against interleaved changes in the same
  hunk; this technique gives clean one-commit-per-triage-unit history without
  relying on hunk-splitting.
- **Where:** `Step 6` commit mechanics, `references/commands.md` §6 in
  `wk-pr-resolve`.
