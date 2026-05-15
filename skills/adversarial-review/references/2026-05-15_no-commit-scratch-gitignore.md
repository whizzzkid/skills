---
class: principle
---

- **Rule:** Never commit a `.gitignore` entry for `.review-playground/` (or any skill scratch dir) on the branch under review. Skill scratch dirs are ephemeral local state — keep the ignore in `~/.gitignore_global` or rely on per-repo opt-in.
- **Why:** Adding `.review-playground/` to the repo's `.gitignore` mid-review surfaces in the PR diff as a meta-change the reviewer didn't ask for. Skill artifacts must not leak into repo state.
- **Where:** Step 4 (Playground Validation) → HARD RULE added adjacent to the `.review-playground/` creation bullet.
