---
class: principle
---

**Rule** — Scan staged **path strings** against `.skillprohibit` per-file, never as a
bare multi-line list:

```bash
git diff --cached --name-only | command grep -iEf .skillprohibit
```

- **A denylist is a pattern file, never a haystack — the direction is part of the rule.**
  The subject text is the *input*; `.skillprohibit` supplies the *patterns* via `-f`. Prose
  of the form "grep X against Y" does not fix which operand is which, so state the flag
  wherever the gate is invoked. Inverted — denylist as haystack, subject as a literal
  needle — the scan degrades to fixed-string matching against pattern *source*: it can only
  hit the denylist's metachar-free lines and silently misses every regex one. It returns
  rc=1 and a clean verdict, so the run gets no signal; the failure is **open**, and the
  canary below is the only thing that distinguishes it.

- **Use `command grep`, never bare `grep`.** A shell function or alias can route `grep`
  to a different implementation; identical flags then yield different semantics, and the
  scan can report **rc=1 with no stderr** on a path the owning hook would flag. Bare
  `grep` making the *canary* fire does not clear the scan — prove the engine on the same
  invocation form the scan uses.

- A stricter `grep` alias false-cleans one bad path inside a multi-line argument.

## The verdict protocol binds every hand-rolled scan this skill runs

A verification rule attached to one *named* scan does not travel to a sibling scan of the
same construction, even inside the same step. Step 5 runs two hand-rolled scans — the
staged **path** scan and the **overfit category** scan over drafted edit text — and both
inherit everything below. Scope the discipline to the construction, never to the name.

- **Branch on the scan's exit status, never on its warning text — and never on a printed
  banner.** rc=1 is "read the input, matched nothing"; rc>=2 is "at least one path was not
  read", never a clean result. Both `scan || echo NONE` and an unconditional
  `echo "(none above = clean)"` after the grep map *every* status onto the clean branch —
  the banner is a decoration, not a verdict. A `No such file` warning is a scan failure,
  and a scan whose stderr is redirected has no warning left to read.
- **One quoted path per invocation, via a read loop.** A multi-path grep returns one status
  for the whole set, and a read failure **dominates a genuine match** — verified on BSD and
  GNU grep, one missing path turns rc=0 into rc=2 while the matching file's hit still
  prints. So a multi-path rc is not attributable to any file, and "did it print anything?"
  is no substitute for it. Worst form: a space-joined path list passed as one quoted
  argument — grep sees a single nonexistent filename, reads nothing, and rc=2 on every
  pattern while the banner still reports clean.

  ```bash
  while IFS= read -r f; do
    command grep -nE "$pat" "$f"; rc=$?
    case $rc in 0) hit=1 ;; 1) ;; *) err=1 ;; esac
  done < paths.txt
  # err=1 -> scan FAILED, not a result;  hit=1 -> HIT;  else clean (input provably read)
  ```
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
  - **Draw the canary from a pattern line that carries a metacharacter** — a metachar-free
    denylist line matches under *both* directions (as a `-f` pattern and as a literal needle
    found in the file), so a canary built from one fires green while proving nothing about
    direction. Only a metachar-bearing line separates the two readings: expanded, it matches
    via `-f` and does not appear verbatim in the pattern file. Verified by driving both
    forms over the same denylist: the metachar-derived canary fired only via `-f`, the
    metachar-free one fired under either.
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

**Where** — wk-sharpen Step 5: the staged **path** scan and the **overfit category** scan,
after the owning hooks run. The verdict protocol above governs both, and any later
hand-rolled scan the skill grows.
