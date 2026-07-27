---
class: principle
---

**Rule** — Never let `}` directly terminate a `sed` command that accepts an optional
argument (`q`, `Q`). Close the command with `;` or a newline inside the brace:

```sh
sed -n '1{/^x$/!q;}'   # portable
sed -n '1{/^x$/!q}'    # aborts the whole script on BSD/macOS
```

Prefer `awk` outright for frontmatter / range extraction.

**Why** — BSD/macOS `sed` parses the `}` as trailing text of `q`'s optional exit-code
argument and aborts the *entire script* with `extra characters at the end of q command`,
producing no stdout for any input. GNU `sed` accepts both spellings, so the script passes
on Linux CI and fails only on macOS.

**Verified against source** — Drove BSD `sed` with the reported extractor
`sed -n '1{/^---$/!q}; 1d; /^---$/q; p'` against a well-formed frontmatter file: rc=1,
empty stdout, the `q command` diagnostic on stderr. Used as a memory-frontmatter
extractor it classified every file as `neither` — an all-reject.

**Sharpened from the report** — The report gave the trigger as "`q` inside `{}` *followed
by further commands*". The reproduction voids that: `sed -n '1{/^---$/!q}'` with nothing
after the block fails identically (rc=1), while `1{/^---$/!q;}`, the newline-separated
form, and top-level `q` with following commands all return rc=0. The trigger is `q}`
adjacency, not what follows the block — so the rule is stated against the brace, and the
report's narrower trigger is recorded here as wrong to avoid it being re-memorized.

**Sibling divergence — why this is not a third silent-zero** — The two `awk` traps (PCRE
shorthand escapes; `END{exit N}` overriding a rule-body status) are silent *at the tool*:
valid program, empty stderr, status 0. This `sed` trap is loud at the tool (rc=1 plus a
diagnostic) and is silenced only by the **call site**. That distinction is load-bearing:
a positive control alone catches the `awk` pair, but catching this one additionally
requires not discarding the status. Folded accordingly as two edits, not one.

**Corollary folded** — A loud per-invocation failure still lands as a silent all-reject
when the caller keeps only stdout: `out=$(parser "$f")` in a per-file loop discards status
and stderr, so a parser aborting on every input returns an empty string every time and
each file falls into the default bucket. Branch on the status; never infer "no match" from
empty stdout alone. Added as a sub-bullet of the existing zero / all-reject rule, which
previously covered only genuinely-silent (status 0) matchers.

**Where** — wk-workstyle-shell → Rules: the brace rule immediately before the existing
`sed -i` portability bullet; the corollary under the positive-control rule.

**Ownership note** — Routed by subject to the skill that already owns the silent-failure /
portability family, extending that fold's single version bump rather than opening a
competing one.
