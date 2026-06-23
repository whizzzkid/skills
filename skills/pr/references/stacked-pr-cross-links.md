---
class: principle
---

**Rule** — When a PR stacks on another PR's head branch, populate the `## Stack` cross-reference links (`[#NNN]({url})`) from the detected base→head ordering in the first `gh pr create` pass — never leave them for manual post-creation `gh pr edit` rounds. Resolve every stack member's number/URL up front, write prev/next links into the body before creation, then back-link the new PR into its immediate parent with a single `gh pr edit`.

**Why** — The skill knows the stack ordering from base-branch detection, so the links are derivable, not manual. Adding them after creation across N PRs breaks DRY and creates maintenance debt: every later description update requires manual re-linking.

**Where** — wk-pr Step 2, Stacked PR section. The stacking signal is `$BEST_BASE == another PR's head branch`.
