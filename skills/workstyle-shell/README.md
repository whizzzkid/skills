# wk-workstyle-shell

> Enforces safe, idiomatic shell conventions in scripts and compound ad-hoc commands.

**Version:** `2026.08.17-202223`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic for shell-script edits and multi-step bash/sh/zsh command composition |
| User-invocable | `/wk-workstyle-shell scan` — full tree; `/wk-workstyle-shell check <path>` — one file |

## Rules at a Glance

- `set -euo pipefail` at the top of every script.
- Quote every variable — `"$var"` not `$var`; unquoted variables split on whitespace.
- `local` for all variables inside functions.
- `[[ … ]]` over `[ … ]` in bash.
- Heredoc for multi-line strings; avoid concatenated `echo` chains.
- Named constants for magic values at the top of the script.
- One-line comment above each function (scripts with ≥3 functions) — describe what it does and any non-obvious output format.
- No `${VAR:?msg}` guard when an `EXIT` trap is registered — bash 3.2 resets `$?` to 0 on `:?` failure; use an explicit `if [[ -z … ]]; then exit 1; fi`.
- Probe capability, don't parse error text — branch on exit code against a known-good input, since stderr wording differs across GNU/BSD/BusyBox and fails closed on the variant it was meant to handle.
- No PCRE shorthand (`\S`, `\d`, `\w`, `\b`) in an `awk` / POSIX-ERE pattern — the unknown escape degrades to an escaped *literal*, so the pattern stays valid, exits 0, and matches nothing; use bracket expressions like `[^[:space:]]`.
- No verdict in an `awk` rule body's `exit N` when `END` also exits with an argument — the rule-body `exit` falls through to `END`, whose status wins, collapsing both branches to one code; set a flag and end with `END { exit !ok }`.
- Prefix `command` on any tool call whose clean/zero result is load-bearing — a bare name hits a shell function or alias first, and an agent shell can wrap a standard tool to re-exec a different engine with implicit options, so the divergence shows up as a missing match rather than an error; `type` showing only an alias is not a clearance, since a non-interactive shell still honors the function.
- Treat any zero / all-reject from a matcher *or a file enumeration* as unproven until a positive control moves the count — every *status-0* silent-zero trap here stays syntactically valid, writes nothing to stderr, and exits 0; run the control in the *same* invocation form as the scan, or it certifies an engine the scan never used.
- Require a control to reach a known *true* count, not merely a changed one — a truncated aggregate still moves 0 → 1, so a "the count changed" criterion clears while the number stays false, and a control demanding "> 1" is unsatisfiable against a capped counter; a plausible wrong number is worse than a missing one, since nothing in its shape signals corruption.
- A loud per-invocation failure still lands as a silent all-reject when the caller keeps only stdout — `out=$(parser "$f")` in a per-file loop discards status *and* stderr, so a parser aborting on every input returns an empty string every time and each file falls into the default bucket; branch on the status rather than inferring "no match" from empty stdout.
- Never let `}` directly terminate a `sed` command taking an optional argument (`q`, `Q`) — BSD/macOS reads the brace as trailing text of the argument and aborts the whole script with `extra characters at the end of q command`, with or without commands after the block; close with `;` or a newline inside the brace, and prefer `awk` for frontmatter/range extraction.
- Never `sed -i` for an in-place edit — BSD/macOS reads the script as the required backup suffix; use `perl -pi -e 's{a}{b};' file`, which behaves identically on both platforms.
- Never write `\|` alternation in a BRE — pass `-E` and use `(A|B)`; BSD/macOS reads `\|` as a *literal pipe*, so the substitution is a no-op at rc=0 with empty stderr. Unlike the two `sed` traps above (which abort loudly), this yields a *wrong result* rather than an error, so gate any load-bearing normalization on a positive control proving the transform fired.
- Never escape `|` in an ERE (`grep -E`, `grep -rE`, `awk`) — the exact inverse of the BRE trap above: `\|` is a *literal pipe*, so `'a\|b\|c'` collapses into the single literal `a|b|c` and one keystroke kills every alternative. Valid pattern, empty stderr, rc=1 — a *unanimous zero* indistinguishable from genuine absence, easily misread as "these records are missing"; prove any alternation pattern live before its zero becomes a verdict.
- Never pair `-l` with `-c` in one `grep` — neither implementation rejects the pair, and `-l` short-circuits each file at its first match, so BSD/macOS caps every count at 1 (a file matching twice reports `file:1`) and interleaves both output shapes, breaking any consumer that splits on `:`; flag order changes nothing, rc=0. Here GNU is the safe one — `-l` simply wins and prints no number — so the false count is macOS-only. Run two invocations when both answers are wanted.
- Never let a line-oriented matcher's zero stand over hard-wrapped prose — the matching unit is the line, so a needle spanning a wrap can never hit: valid pattern, empty stderr, rc=1, indistinguishable from genuine absence and *load-bearing* wherever the zero gates a deletion. The mismatch is systematic — prose is wrapped to a column budget while the phrases quoted out of it are not. Normalize first (`tr '\n' ' ' | tr -s ' '`) and run *both* controls in that form, since collapsing structure can turn a false zero into a false positive. Count that normalized stream with `grep -o … | wc -l`, never `-c` — normalizing collapses the file to one line, so `-c` (which counts matching *lines*) caps at 1 however many occurrences exist, leaving the known-true-count rule above unsatisfiable by construction; one counting fix silently installs the next.
- Never pass a variable pattern as a bare `grep` operand — use `grep -e "$pat"`. A pattern beginning with `-` is parsed as options, and unlike the BSD reordering quirk this is POSIX everywhere. The failure is bimodal: an unrecognized letter aborts loudly (`grep "-Werror" f` → rc=2), but a pattern that *is* a valid option is consumed as one, the file operand becomes the pattern, and `grep` reads stdin — so `grep "--color" f` returns rc=1 with empty stdout *and* empty stderr, scoring a false MISSING for the needle's first character alone. `--` also fixes it but demotes every later word to an operand.
- `printf` silently re-runs its format string when arguments outnumber conversion specifiers — `printf '%s=%s\n' a 1 b 2` emits *two* rows, not one. rc=0, empty stderr, identical across the bash/zsh/sh builtins and `/usr/bin/printf`. This is the inverse polarity of every zero-trap above: the count comes out too *high*, so a row-counting probe reading `2` where the loop ran once looks like corroboration rather than corruption. Make the argument count an exact multiple of the specifier count.
- Presence-check with a test builtin, never a value expansion — `${VAR:-NO}` emits the value on the set path, so a `${VAR:+yes}${VAR:-NO}` "boolean" leaks a live secret; fingerprint with length + hash prefix when a value must be compared.
- Keep every shell command portable to zsh as well as bash — ad-hoc commands the agent composes mid-task, not just documented snippets — an unquoted *parameter* expansion never word-splits under zsh in *any* position (`cmd $FILES` hands the tool one argument naming a blob it was never given, so the run reads as a clean zero), `${!var}` aborts as `bad substitution`, and `${PIPESTATUS[…]}` is never populated (zsh spells it `pipestatus`); never materialize a file list in a variable at all — pipe the producer into a `while IFS= read -r` loop — and use `printenv` exit status plus a pipeline-free status probe.
- Never use lowercase `path` as a zsh loop or script variable, including in compound ad-hoc commands — it is a special
  array tied to `PATH`, so scalar assignment replaces the executable search
  path. Prefer role-specific names such as `doc_path`.
- Never pair `|| echo <default>` with a command that prints on its non-zero path, and never let that fallback carry a *verdict* — `grep -c` writes `0` *and* returns rc=1 (so the default appends rather than substitutes), while `scan || echo NONE` maps rc=1 "matched nothing" and rc>=2 "never read the input" onto one clean branch. Only stderr separates the two, so a scan that redirects it keeps no signal; discriminate all three statuses and treat rc>=2 as an aborting scan failure.
- **Important:** Portability breaks in *both* directions — a zsh-only glob qualifier is reparsed, not ignored, when
  `bareglobqual` is off. `*.md(N)` silently means "files ending `.mdN`", so it reports `no matches found` on a
  directory full of `.md` files and matches the wrong files with status 0 once a `.mdN` exists. Enumerate with
  `find … -print` into `while IFS= read -r`.
- A guard's verdict that contradicts the output it summarizes indicts the guard — an unset `${PIPESTATUS[0]}` plus a `${rc:-0}` default reports a *pass* for a failed command, so re-derive the status dialect-independently before believing the green.
- Keep non-assertive previews out of `pipefail` gates — an early-closing consumer can give the producer SIGPIPE
  (often rc 141), aborting before the real assertions. Remove the preview or drain its full input.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- **Neither vendor is the portable default.** Most rules here name a vendor because the GNU
  spelling fails silently or destructively on BSD/macOS — option reordering, `sed -i`,
  stderr wording — but the direction is not universal: with `grep -lc` it is BSD that
  manufactures a false count while GNU degrades safely. Never infer which side is at risk
  from the majority; write the form that works on both rather than branching.
- `set -euo pipefail`, quoted variables, and `local`-scoped function vars are baseline; `[[ ]]` over `[ ]` in bash.
