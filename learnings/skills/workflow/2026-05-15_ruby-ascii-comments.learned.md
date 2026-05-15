---
skill: wk-workflow
date: 2026-05-15
type: correction
severity: medium
---

Use only ASCII characters in Ruby source comments.

**What happened:** Commits were blocked by rubocop `Style/AsciiComments` because em dashes (—) were used in inline comments in `.rb` files. Required two extra fix commits.

**Root cause:** The em dash is a natural documentation character but rubocop-$EMPLOYER enforces ASCII-only comments. The skill's code-standards section doesn't call this out.

**Suggested fix:** Add to the Code Standards section: when writing Ruby source comments, use plain ASCII (`-`, `->`, `--`) instead of Unicode punctuation (em dash, smart quotes, ellipsis). This applies to `.rb` files and bin scripts loaded as Ruby.
