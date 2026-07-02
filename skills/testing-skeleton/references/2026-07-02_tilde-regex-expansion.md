---
class: principle
skill: wk-testing-skeleton
date: 2026-07-02
---

# Assert literal-tilde strings with a quoted glob, not a regex

**Rule:** An unquoted leading `~` on the right of a bash `[[ =~ ]]` is
tilde-expanded to `$HOME` before the regex evaluates, so a pattern meant to match
a literal tilde (or a tilde-prefixed home path) instead matches the expanded
`$HOME` value.
- Assert a literal-tilde string with a quoted glob so no expansion happens:
  `[[ "$output" == *'~'* ]]`; quote any tilde-prefixed path segment the same way.
- When the substring can match a superset, add a negative assertion excluding it.

**Why:** The assertion passes or fails for the wrong reason — a broken literal
match looks green because the tilde-expanded pattern coincidentally matched, or a
correct output looks red because the pattern became the expanded home path.

**Where:** Stage 3: Write the tests — shell-test assertion gotchas.
