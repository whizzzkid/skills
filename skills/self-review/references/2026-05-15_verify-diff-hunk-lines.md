---
class: principle
---

- **Rule:** Before POSTing a self-review, verify each comment's `line` falls inside a `@@` hunk range from `git diff <base>...HEAD -- <path>`. Snap out-of-hunk comments to nearest in-hunk line or convert to file-level (omit `line` and `side`).
- **Why:** GitHub's review API rejects out-of-hunk lines with `422 "Line could not be resolved"`. Absolute file line numbers from `Read` are not commentable unless they appear in a diff hunk.
- **Where:** New Step 3.5 "Validate every comment line lies inside a diff hunk" inserted between Step 3 and Step 4 with the hunk-range extraction recipe.
