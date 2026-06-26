---
skill: wk-workstyle-ruby
date: 2026-06-26
type: gap
severity: medium
---

Run `bundle exec rubocop` locally before staging Ruby changes to catch layout and style violations before CI.

**What happened:** Two RuboCop violations were caught by CI after push — `Layout/FirstMethodArgumentLineBreak` on a multi-element array passed to `expect().to eq(...)`, and `Style/AsciiComments` on an em-dash used in a spec comment. Both required a follow-up fix commit.

**Root cause:** The workstyle-ruby pass ran conceptually but did not include an explicit `bundle exec rubocop <changed-files>` invocation before staging. RuboCop layout rules (argument line breaks, non-ASCII comment characters) are not reliably caught by code inspection alone — the linter must run.

**Suggested fix:** Add a mandatory `bundle exec rubocop --no-color <changed-files>` step to the pre-commit checklist in wk-workstyle-ruby. Run it on every changed `.rb` file before staging; fix all offenses before proceeding to `wk-commit`.
