---
skill: wk-git
date: 2026-07-22
type: surprise
severity: low
---

Plain `grep` gave a false negative on tracked file content that `git grep` found.

**What happened:** Verifying whether a symbol existed in a large source file,
plain `grep <pattern> <file>` returned nothing while `git grep <pattern>` on the
same working tree found the match. The agent nearly concluded the code was absent
and re-implemented it.

**Root cause:** Plain `grep` is subject to the working directory, the exact path
passed, binary/encoding heuristics, and locale/`GREP_OPTIONS` quirks that can
suppress a match; `git grep` searches tracked content through git's own index and
is not affected by those. In this repo the discrepancy was reproducible.

**Suggested fix:** For "does this symbol/string exist in the repo?" verification,
use `git grep` (or the ripgrep-backed search tool), never plain `grep <file>`. A
plain-`grep` empty result is not proof of absence — confirm with `git grep`
before acting on "not found".
