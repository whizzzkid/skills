---
class: principle
date: 2026-05-29
severity: medium
---

- **Rule:** After a pre-commit-hook-blocked commit in a batch run, run
  `git status --short` before staging the next group; fix-and-retry the blocked
  commit or `git restore --staged <files>` first. Author new sibling READMEs with
  relative `wk-*` links from the first draft.
- **Why:** A blocked `git commit` exits non-zero but leaves the index staged — the
  next `git add` sweeps those files in, merging two skills into one commit. Bare
  `wk-*` names trip the link-check hook and force a re-commit.
- **Where:** Step 8 "Verify and Commit" → Commit item (staged-state guard +
  relative-link sub-bullets).
