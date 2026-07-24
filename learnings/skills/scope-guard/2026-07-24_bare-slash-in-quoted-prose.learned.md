---
skill: wk-scope-guard
date: 2026-07-24
type: gap
severity: medium
---

A bare `/` inside unrelated quoted prose (an `echo` progress banner) in a compound command is
treated as a search root, false-blocking a fully repo-scoped `grep`.

**What happened:** A repo-scoped search ran as one compound command — an `echo` banner, then a
recursive `grep` restricted to repo-relative paths. The guard blocked it with `Out-of-scope path: /`.
No argument of the `grep` was `/`; the only `/` on the line was a word separator inside the banner
text. Minimal reproduction (verified, blocks every time):

```bash
echo "=== a / b ==="; grep -rn 'token' <repo-relative-dir>
```

Dropping the space-delimited `/` from the banner makes the identical `grep` pass. The block also
fires when the banner and the search are separated by `;`, so the two are not being associated by
proximity — the whole line is scanned as one token stream.

**Root cause:** Path-like tokens are collected from the entire compound command line rather than
from the argument list of the search command being guarded. A lone `/` is then classified as a
filesystem-root target. Two compounding factors: (a) tokens inside quoted strings are not excluded,
so arbitrary prose can synthesize a path token; (b) tokens are not attributed to the specific
command whose scope is under test, so a token belonging to `echo` is charged against `grep`.

**Suggested fix:** Attribute path tokens to the command they are arguments of — split the line on
shell separators first, identify the search invocation, then scan only that segment's arguments.
Additionally skip tokens that originate inside a quoted string when the enclosing command is not a
search command. A bare `/` should also require being a standalone argument, not merely a
space-delimited character in a string. Verify the fix against the reproduction above and against a
genuinely out-of-scope search (`grep -r x /etc`) so the guard is not relaxed — the true-positive
case must still block.
