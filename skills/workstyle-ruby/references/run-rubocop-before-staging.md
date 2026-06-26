---
class: principle
---

**Rule:** Run `bundle exec rubocop --no-color <changed-files>` on every changed
Ruby file before staging; fix all offenses before committing.

**Why:** Layout and style cops (argument line breaks, non-ASCII comment
characters) are not reliably caught by code inspection alone — only the linter
sees them. Skipping the local run defers the catch to CI and forces a follow-up
fix commit.

**Where:** `## Verify with RuboCop` step, before `## Apply or Report`.
