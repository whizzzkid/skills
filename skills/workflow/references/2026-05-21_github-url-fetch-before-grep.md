---
name: github-url-fetch-before-grep
description: For GitHub comment / review URLs in user input, fetch via gh api before codebase grep.
class: principle
---

- **Rule:** When the user's message contains a GitHub comment or
  review URL, run
  `gh api repos/{owner}/{repo}/{pulls|issues}/comments/{id}` first.
  Defer codebase grep until the comment body is read.
- **Why:** The comment text usually contains the exact diagnostic
  the user wants you to act on. Codebase grep before reading the
  artifact wastes a turn and signals inattention to user-supplied
  scope.
- **Where:** Phase 1 "Investigate user-provided artifacts first",
  new sub-bullet under the general "fetch/read directly" rule.
