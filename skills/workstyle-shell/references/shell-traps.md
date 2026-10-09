# Shell Traps — sed, awk, perl, grep, printf

Catalog of silent-failure traps in common shell tools. Each trap produces valid
output, empty stderr, and exit status 0 — making broken matchers indistinguishable
from correct results.

## BSD/macOS Operand Order

On macOS/BSD, options are not reordered after the first operand. `mv src -v`
treats `-v` as the *destination*, silently renaming `src` to `./-v` — GNU would
read it as a flag. Put flags before operands, or terminate options with `--`.

## Variable Patterns as grep Operands

Never pass a variable pattern as a bare `grep` operand — use `grep -e "$pat"`. A
pattern beginning with `-` is parsed as options; unlike the BSD rule above this is POSIX
everywhere, and the pattern already *is* before the operand. The failure is bimodal and
the quiet half is the dangerous one: an unrecognized letter aborts loudly (`grep "-Werror"
f` → rc=2, `invalid option -- W`), but a pattern that happens to *be* a valid option is
consumed as one — the file operand then becomes the pattern and `grep` reads **stdin**, so
`grep "--color" f` and `grep "-x" f` return rc=1 with empty stdout *and* empty stderr. A
needle scores a false MISSING for its first character alone, and an interactive stdin
hangs rather than returns. `-e` binds the next word as a pattern in any position; `--`
also fixes it but demotes every later word to an operand, so a trailing `-r` silently
becomes a filename. Applies to any tool taking a pattern or path operand from a variable.

## PCRE Shorthand in awk/POSIX-ERE

Never use PCRE shorthand escapes in an `awk` / POSIX-ERE pattern — `\S`, `\s`,
`\d`, `\w`, `\b` do not exist in ERE. `awk` treats the unknown escape as the escaped
*literal* character, so `type:[[:space:]]*\S` silently becomes "…then a literal `S`":
syntactically valid, no stderr warning, exit status 0, and zero matches. Use bracket
expressions — `[^[:space:]]`, `[[:space:]]`, `[0-9]`, `[A-Za-z0-9_]` — or reach for
`grep -E` / `perl` when genuine PCRE semantics are required.

## awk exit Status Overwrite

Never carry a verdict in an `awk` rule body's `exit N` when `END` also exits with an
argument. `exit` in a rule body stops reading input but *falls through to `END`*, and
an argument-bearing `END { exit 1 }` replaces the status — so the qualifying and
rejecting branches converge on one code, yielding a silent all-reject. Set a flag and
let `END` compute the verdict; an arg-less `exit` preserves the rule-body status:

```awk
/qualifies/ { ok = 1; exit }   # stop reading, fall into END
END { exit !ok }
```

Identical in BSD `awk` and `gawk` — POSIX semantics, not a vendor quirk.

## awk ENVIRON[] vs -v Assignment

`awk`'s `ENVIRON[]` and `-v` / `var=val` assignments are disjoint — `export` anything you
intend to read through `ENVIRON[]`, or read a `-v` variable by its bare name. The lookup
expands to the empty string with rc=0 and empty stderr, and an empty needle makes a per-item
check report a *unanimous pass it never performed* — inverse polarity to the two `awk` traps
above. Worked example:
[`2026-07-27_environ-disjoint-from-v-assignment.md`](2026-07-27_environ-disjoint-from-v-assignment.md).

## Illegal Byte Sequence

`Illegal byte sequence` points to upstream byte truncation, not UTF-8
itself. Fix the byte slice, or pin `LC_ALL=C` on the consumer when byte-wise
comparison is intended. A clean `grep`/`sed`/`uniq` run does not prove the
stream is valid. See [truncated multibyte
streams](2026-07-27_truncation-breaks-locale-consumer.md).

## Command Shadowing

Prefix `command` on any tool call whose clean/zero result is load-bearing. A bare
name resolves to a shell function or alias *before* the binary, and an agent shell may
wrap a standard tool to re-exec a **different engine** with implicit options the caller
never passed (file filtering, dialect changes). Identical flags then diverge in
semantics, and the divergence surfaces as a **missing match, not an error** — empty
output, empty stderr, so a gate reads clean. `type <name>` reporting only an alias is
not a clearance: a non-interactive shell skips alias expansion yet still honors the
function. Probe both layers before trusting a zero:

```bash
declare -f grep                       # the alias can hide a function behind it
grep --version; command grep --version  # different engines print different banners
```

## Positive Control Rule

Treat any zero / all-reject result from a matcher or a file enumeration as unproven
until a positive control moves the count. Every *status-0* silent-zero mechanism here
— the two `awk` ones, a reparsed glob qualifier, and a shadowed command name — yields a
valid program, empty stderr, and status 0, so a broken matcher is indistinguishable from
a real finding. Feed one input known to qualify and confirm the count changes.

- **Run the control in the same invocation form as the real scan, in the same command.**
  A control run bare while the scan runs `command`-prefixed (or the reverse) certifies
  an engine the scan never used — it proves nothing about the result being cleared.
- **A loud per-invocation failure still lands as a silent all-reject when the caller
  keeps only stdout.** `out=$(parser "$f")` in a per-file loop discards both status and
  stderr, so a parser that aborts on *every* input returns an empty string every time
  and each file falls into the default bucket. The tool is screaming; the call site sees
  a clean empty result. Never infer "no match" from empty stdout alone — branch on the
  status (`out=$(parser "$f") || return`) and keep the positive control.
- **Require the control to reach a known *true* count, not merely a changed one.** A
  truncated aggregate still moves 0 → 1, so a "the count changed" criterion clears while
  the number stays false; conversely a control demanding "> 1" is unsatisfiable against a
  capped counter and reads as a permanent failure to explain away. A plausible wrong
  number is worse than a missing one — nothing in its shape signals corruption — so
  confirm the counting flag's own semantics before any count becomes evidence.

## sed Traps

- **Never let `}` directly terminate a `sed` command that takes an optional argument**
  (`q`, `Q`). BSD/macOS `sed` reads the brace as trailing text of the argument and aborts
  the entire script with `extra characters at the end of q command` — whether or not any
  command follows the block, so "only when more commands follow" is the wrong trigger to
  memorize. Close with `;` or a newline inside the brace: `sed -n '1{/^x$/!q;}'`, never
  `sed -n '1{/^x$/!q}'`. GNU accepts both spellings, so the script passes on Linux CI and
  aborts on macOS. Prefer `awk` outright for frontmatter/range extraction.
- **Never emit `sed -i` for an in-place edit.** BSD/macOS `sed` requires an explicit
  backup-suffix argument, so the GNU spelling `sed -i 's/a/b/' file` consumes the
  script as the suffix and fails. Use `perl -pi -e 's{a}{b};' file` — identical
  semantics on both platforms, no platform branch, and `{}` delimiters avoid escaping
  slashes in paths. Reserve `sed` for read-only stream transforms.
- **Never write `\|` alternation in a BRE — pass `-E` and use `(A|B)`.** POSIX BRE has
  no alternation operator, and BSD/macOS `sed` reads `\|` as a **literal pipe**, so
  `s/^\(A\|B\): //` matches only the three-character run `A|B` and leaves every intended
  line byte-identical, rc=0, empty stderr. GNU implements `\|` as an extension, so the
  same script strips correctly on Linux CI and silently no-ops on macOS. **A different
  failure mode from the two `sed` traps above:** those abort at the tool (loud unless a
  `$(…)` call site keeps only stdout), whereas a no-op substitution is indistinguishable
  from a correct pass-through — a *wrong result*, not an error, consumed as data with
  nothing to diagnose. A prefix that silently survives normalization makes every entry
  miss its counterpart downstream, inverting the verdict for an entire source. Check
  which of the two you face before reaching for a diagnostic: gate any load-bearing
  normalization on a positive control proving the transform actually fired.

## perl Line-Mode Traps

- **Never end a `perl -p`/`-pi` substitution with `\s*$` — use `[ \t]*$`.** Under `-p`, `$_` still carries the
  line's trailing `\n`, and `\s` matches it, so `s/^(key:\s*)"old"\s*$/$1"new"/` deletes the newline and joins the
  edited line to the next one. rc=0, no warning; in YAML frontmatter the next key lands on the same line and the
  file silently stops parsing. Match horizontal whitespace only (`[ \t]*$`), or add `-l` to chomp and restore
  newlines.
- **Diff any structured file (frontmatter, YAML, JSON) after a bulk regex edit** — `git diff` the touched set, or
  re-parse it; a line-join is invisible in the success output.

## ERE Escaped Pipe

Never escape `|` in an ERE (`grep -E`, `grep -rE`, `awk`) — `\|` is a literal pipe.
The exact inverse of the BRE rule above, with the same silent failure: `'a\|b\|c'` under
`-E` is not "a or b or c" but the single literal `a|b|c`, so one keystroke kills every
alternative at once. Valid pattern, empty stderr, rc=1 — a **unanimous zero** across every
file searched, indistinguishable from genuine absence and readily misread as "these records
are missing", manufacturing work to restore what was never gone. The two characters mean
opposite things in the two dialects, so the habit carried either direction disables the
match with no diagnostic. Prove any alternation pattern live before its *zero* becomes a
verdict (positive-control rule above); a zero unanimous across several independent
alternation patterns indicts the pattern syntax first, the data only after the control fires.

## grep -l with -c

Never pair `-l` with `-c` in one `grep` — BSD silently caps every count at 1. The
flags contradict in intent and neither implementation rejects the pair; `-l`
short-circuits each file at its first match, so the counter never advances past it. On
BSD/macOS a file containing the term twice reports `file:1`, and the stream *interleaves
both output shapes* — `file:count` lines plus bare filename lines — so a consumer
splitting on `:` mis-parses the bare names. Flag order (`-lc` / `-cl`) changes nothing;
rc=0, empty stderr. The platform split runs **opposite** to the `sed` traps above: GNU
degrades safely (`-l` wins, no number printed at all), so the plausible-but-false count
is the macOS-only outcome and Linux CI looks clean. Pick the flag matching the question
— `-l` for which files, `-c` for how many — and run two invocations when both are wanted.

## Hard-Wrapped Prose Matching

Never let a line-oriented matcher's zero stand over hard-wrapped prose — its matching
unit is the line, so a needle spanning a wrap can never hit. A quoted phrase longer than
the columns left on a wrapped line is broken by a newline plus leading indent, so no single
line holds it: valid pattern, empty stderr, rc=1 — indistinguishable from genuine absence,
and *load-bearing* wherever the zero certifies "not stated here" and gates a deletion. The
mismatch is systematic, not occasional: prose is wrapped to a column budget by convention
while the phrases quoted out of it are not, so the two are mismatched by construction.
Normalize the unit up to the needle first — `tr '\n' ' ' | tr -s ' '` — and run **both**
controls in that same normalized form, since collapsing structure the needle relied on can
turn a false zero into a false positive. **Count that normalized stream with `grep -o … |
wc -l`, never `-c`:** normalizing collapses the file to one line and `-c` counts *matching
lines*, so it caps at 1 however many occurrences exist — leaving the known-true-count rule
above unsatisfiable by construction rather than by any defect, one counting fix silently
installing the next. General form of the trap: the matcher's unit must be at least as large
as the needle, and a count is evidence only where its counting unit survives every transform
applied upstream of it.

## printf Format Reuse

`printf` reuses its format when arguments outnumber conversion
specifiers. Match arity exactly; emit one record per call, or assemble it
and print with one `%s\n`. Surplus arguments create plausible extra rows with
rc 0. See [format
reuse](2026-07-26_printf-format-reuse-doubles-rows.md).

## Fallback Traps

- **Never pair `|| echo <default>` with a command that prints its result on the non-zero
  path.** The idiom assumes non-zero means *failed, emitted nothing* — true where exit
  status signals an **error**, false where it is a **predicate about the result**, whose
  failure path is a successful run that found nothing and already printed. `grep -c`
  writes `0` *and* returns rc=1, so `n=$(grep -c -e "$pat" f || echo 0)` appends instead
  of substituting and `n` becomes the two-line string `0\n0`. `[ "$n" -eq 0 ]` then exits
  **2** (`integer expression expected`) — neither true nor false, so the misfire
  direction is set by the guard's polarity, not by the data: `[ … ] && flag` skips the
  branch and scores the item clean, `if [ … ]; then … else flag; fi` takes the `else` and
  flags a present item, and under `set -e` the 2 aborts the run mid-loop. **Third
  polarity of the counting traps above:** not too low, not too high, but *non-numeric* —
  and the corruption (`0`, then `0`) is the exact digit the fallback existed to supply,
  so the tally reads plausibly either way. Classify the status before writing any
  fallback (`diff` is predicate-status too — it prints the delta *and* returns 1), then
  capture output and default only on genuine emptiness:

  ```bash
  n=$(command grep -c -e "$pat" "$file"); n=${n:-0}
  ```

  - **Verdict-level twin — the fallback carries a *conclusion*, not a value: `scan || echo
    NONE` maps rc=1 (read the input, matched nothing) and rc>=2 (a path it could not
    read) onto one clean branch.** The value trap appends a wrong number; this one
    asserts a wrong conclusion,
    and on a prohibited-content gate the wrong conclusion is what ships the content. Only
    stderr separates the two, so a scan that redirects stderr keeps no signal at all.
    Discriminate all three statuses and treat rc>=2 as an aborting scan failure:

    ```bash
    rc=0; command grep -nE "$pat" "$f" || rc=$?
    case $rc in 0) echo MATCH ;; 1) : ;; *) echo "SCAN FAILED: $f" >&2; exit 1 ;; esac
    ```

  - **`-s`/`-q` decide which status wins — neither is cosmetic.** `-s` hides the
    *message* for a missing or unreadable path, never the status, removing the one
    signal that separated rc=1 from rc>=2. Precedence also flips: without `-q` an
    unreadable path yields rc=2 **even when the pattern matched another file**; with
    `-q` a match yields rc=0 **even when a path errored**, so `grep -sq` over a path
    set reports success whenever anything matched and swallows the failed path.
    Verified identical on BSD and GNU greps — never branch on a supposed
    BSD-vs-GNU status difference. Where a path may be absent, test `[[ -f "$f" ]]`
    first or judge the check on its output, never status alone.

## Pipeline Verdict Loss

**Important — never pipe a scan whose exit status you act on into `head`/`tail`/
`sort`/`wc`.** `$?` after a pipeline is the *last* command's status, and a limiter
always succeeds, so the pipeline reports 0 whether the scan matched, matched
nothing, or never read its input. Which way it lies is set by the guard's
polarity, not the result: `rc == 0` → hit
scores a false **hit** on a clean scan, `rc != 0` → clean scores a false **clean**
on a real one. This is the pipeline sibling of the hard-coded banner: a second way
to lose the rc a verdict must come from. A limiter added for readability silently
becomes the status source. Run the scan bare, or redirect to a file and read `$?`
(`grep -c`-style counts are a *value*, not a verdict — piping those is fine):

```bash
rc=0; command grep -nE "$pat" "$f" > "$out" || rc=$?   # verdict survives
command grep -nE "$pat" "$f" | head; echo $?           # WRONG — always 0
```

## Pipefail and Non-Assertive Previews

Keep non-assertive previews out of `pipefail` gates. Early-closing consumers can give producers SIGPIPE
(often rc 141), aborting before assertions. Remove the preview or drain its full input; make each gate command
assert one property.
