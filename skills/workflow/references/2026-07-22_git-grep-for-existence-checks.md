---
class: principle
---

- **Rule**: For "does this symbol/string exist in the repo?" verification, use
  `git grep` (or the ripgrep-backed search tool), never plain `grep <file>`. A
  plain-`grep` empty result is not proof of absence — confirm with `git grep`
  before acting on "not found".
- **Why**: Plain `grep` is subject to the working directory, the exact path
  passed, binary/encoding heuristics, and locale/`GREP_OPTIONS` quirks that can
  suppress a real match; `git grep` searches tracked content through git's index
  and is not affected. A false negative can trigger a needless re-implementation.
- **Where**: wk-workflow implementation/verification (existence checks before
  writing code). Reference-only: SKILL.md is at its size ceiling and this is low
  severity.
