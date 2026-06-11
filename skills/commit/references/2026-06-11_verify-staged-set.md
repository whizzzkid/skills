---
class: principle
---

- **Rule** — Before a grouped commit, verify the staged set with
  `git diff --cached --name-only` and unstage strays; `git commit` commits the
  whole index, not just the paths just `git add`-ed.
- **Why** — A prior `git mv` sat in the index and rode into an unrelated
  hook-infra commit, merging two logical groups.
- **Where** — "Verify the staged set before a grouped commit" sub-section.
