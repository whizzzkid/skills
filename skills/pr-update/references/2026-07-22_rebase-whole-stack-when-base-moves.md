---
class: principle
---

- **Rule**: When a stacked PR's base moves (parent merges externally, or
  auto-update-branch merges the new default into a descendant), rebase the whole
  stack onto the new base with `git rebase --onto <newbase> <oldbase> <branch>
  --update-refs` — never patch around the injected merge commit. Detect an
  auto-merge by comparing the remote branch head against locally-fetched history
  (an unknown-SHA/`bad object` head means re-fetch and inspect first).
- **Why**: Auto-update-branch merges inject an unrelated delta and a synthetic
  `Merge branch …` commit and retarget the base; patching around them pollutes
  the diff-vs-new-base.
- **Where**: wk-pr-update Stage 3a (rebase / upstream-deletion handling).
