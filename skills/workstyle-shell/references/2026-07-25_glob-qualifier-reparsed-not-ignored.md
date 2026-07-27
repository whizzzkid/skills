---
skill: wk-workstyle-shell
class: principle
---

**Rule** — Never let a composed shell command depend on a zsh glob qualifier (`(N)`,
`(.)`) or on `nullglob`/`failglob` state. Enumerate with `find … -print` fed through
`while IFS= read -r`.

**Why** — Verified by reproduction under zsh 5.9 with `bareglobqual` **off** (its state in
an agent shell). With the option off the qualifier is *reparsed, not ignored*: `(N)` is
read as a pattern group matching a literal `N`, so `*.md(N)` silently means "files ending
`.mdN`". Two consequences, both proved:

- On a directory holding two real `.md` files the glob raised `no matches found` — the
  false-empty fires on **non-empty** input, not merely on an empty directory.
- After creating a `zz.mdN` file the same glob matched *that file only*, status 0, no
  error — a false-*positive* enumerating the wrong set, which no exit-status check catches.

**Correction to the reported cause** — the field report framed this as the qualifier "not
being honored", i.e. an unmatched pattern failing to expand to nothing, and guessed at a
non-interactive invocation or emulation setting. Reproduction sharpened both: the operative
mechanism is `nobareglobqual` re-parsing the qualifier into the pattern, and the danger is
strictly larger than reported because a directory full of matches still reads as empty and
a wrong-set match returns success. The rule is written against the verified mechanism.

**Mirror-image framing** — the catalog's first three traps are all *bash-only constructs
failing under zsh*, so a reader who cleared a command against all three finds a *zsh-only*
construct clean. The intro now states that traps run in both directions.

**Consolidation** — the pre-existing `awk` positive-control rule was widened to cover any
matcher *or file enumeration* zero rather than adding a second, near-duplicate rule; an
enumeration yielding zero is exactly the result this trap fabricates.

**Where** — wk-workstyle-shell, zsh-portability trap catalog (fourth entry) and the
positive-control rule.
