---
class: principle
---

**Rule** — Scan staged **path strings** against `.skillprohibit` per-file, never as a
bare multi-line list:

```bash
git diff --cached --name-only | command grep -iEf .skillprohibit
```

- **Use `command grep`, never bare `grep`.** A shell function or alias can route `grep`
  to a different implementation; identical flags then yield different semantics, and the
  scan can report **rc=1 with no stderr** on a path the owning hook would flag. Bare
  `grep` making the *canary* fire does not clear the scan — prove the engine on the same
  invocation form the scan uses.

- A stricter `grep` alias false-cleans one bad path inside a multi-line argument.
- **Branch on the scan's exit status, never on its warning text.** rc=1 is "read the input,
  matched nothing"; rc>=2 is "never read it" — `scan || echo NONE` maps both onto the clean
  branch. A `No such file` warning is a scan failure, not a clean result, and a scan whose
  stderr is redirected has no warning left to read.
- **Important:** treat a hand-rolled `NONE` as **unverified** until the grep is proven to
  fire: probe it with a literal expanded from a real **non-comment, non-blank** denylist
  line (`a[-_]?b` → `a-b`) — never a guess, and never a comment line: a plain-prose
  comment is itself a valid regex matching its own text, so the probe "fires" while
  proving nothing. (Only *plain-prose* comments self-match — one carrying regex
  metacharacters does not, so a comment-line probe can also false-*clean*. Either way it
  proves nothing; use a real pattern line.)
  - **Expand the pattern; never paste pattern source as the subject.** The denylist holds
    regexes, so pattern text and matching text are different strings: resolve every
    metacharacter (`[-_]?` → one literal char, drop `\b`, expand quantifiers) to reach a
    subject the pattern really matches. Pasted verbatim, `a[-_]?b` is five literal
    characters the pattern `a[-_]?b` cannot match.
  - **A failed control indicts the control, not the matcher.** Repair the canary and
    re-run before concluding anything about the grep; a red canary never licenses swapping
    the primitive (Step 1 verification-tooling rule).
  - **Keep the canary in memory** — `printf … | grep -f`, never a staged file. The subject
    is by construction a prohibited term, so writing it to a path trips the very hook under
    test and pollutes the tree.

**Never reimplement an owning hook's matcher** — run the script itself against the staged
index:

- A hook's pattern file is the script's **private config** — often gitignored, so comment
  style and matcher constructs (PCRE `(?i)`) vary per checkout. A hand-rolled `grep -iEf`
  then returns a silent NONE — rc=1, no stderr — on a term the hook flags.
- **Never audit comment style to license a hand-roll.** The governing risk is the
  false-*clean*, and comment style is no evidence against it.

**Why** — Content hooks grep the diff and the commit message, never filenames, so a
prohibited term living in a slug or filename ships clean. Pick a generic slug for a
prohibited-subject lesson up front; never derive it from the subject. Scrub staged
`.learned.md` / retro archives too — a rename commits them publicly, and a
term-handling learning's example IS the term.

**Where** — wk-sharpen Step 5, mechanical overfit scan, after the owning hooks run.
