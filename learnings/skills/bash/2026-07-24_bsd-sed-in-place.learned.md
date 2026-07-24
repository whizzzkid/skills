---
skill: wk-bash
date: 2026-07-24
type: surprise
severity: low
---

`sed -i` is not portable — on BSD/macOS it consumes the next argument as a
backup suffix; use `perl -pi -e` for in-place edits instead.

**What happened:** An in-place edit written as `sed -i 's/a/b/' file` (GNU form)
failed on macOS, where `-i` requires an explicit suffix argument and therefore
swallowed the script. Rewriting as `perl -pi -e 's{a}{b};' file` worked
unchanged on both platforms.

**Root cause:** GNU and BSD `sed` disagree on whether `-i` takes an argument, and
the agent defaulted to the GNU spelling without checking the platform.

**Suggested fix:** Never emit `sed -i` in a cross-platform command. Prefer
`perl -pi -e '<expr>'` for in-place substitution — identical semantics, no
platform branch, and `{}` delimiters avoid escaping slashes in paths. Reserve
`sed` for read-only stream transforms.
