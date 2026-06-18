---
class: principle
---

**Rule:** Stage files from the repo root — `git -C "$(git rev-parse --show-toplevel)" add <paths>` — for conflict resolution and fixes alike.

**Why:** When the session cwd is a repo subdirectory, `git add <repo-relative-path>` exits 128 ("pathspec did not match any files") because the path is unresolvable from the subdirectory.

**Where:** Step 2 (conflict staging) and Step 6 (fix staging).
