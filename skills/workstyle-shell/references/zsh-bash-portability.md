# Zsh/Bash Portability

Keep every shell command the agent runs portable to zsh, not just bash — one a skill
documents *and* one composed ad-hoc mid-task. The agent's shell is not guaranteed to
be bash, and a shell-dependent expansion fails as a plausible *domain* error (nothing
matched, var missing) rather than a syntax error, so it is diagnosed as a real result.
Portability is a property of the shell, never of the authoring context — an ad-hoc
command passes no review, so the trap lands there unchallenged. Traps run **both**
directions — a bash-ism zsh rejects, *and* a zsh-ism the shell declines to honor — so
clearing a command against the bash-only entries below proves nothing. Five traps:

- **Very important:** unquoted **parameter** expansion does not word-split under zsh — in
  **any** position, not only a `for` list. `for x in $LIST` runs the body once over the
  whole newline-joined blob; `cmd $FILES` hands the tool a *single* argument containing
  every path, so it reports `No such file or directory` naming a blob it was never
  given. Either way every element-wise command fails and any no-match sentinel survives
  untouched, so the run reads as a clean zero. Never materialize a file list in a variable
  at all — pipe the producer into the loop (`producer | while IFS= read -r x; do …; done`),
  one operand per call, so the unquoted form is never available to compose; `<<< "$LIST"`
  is safe but leaves the blob in scope for the next line to expand bare.
  (Unquoted **command substitution** `$(cmd)` does split under both, but still breaks on
  whitespace within an element.)
- `${!var}` indirect expansion — bash-only; aborts the whole snippet under zsh with
  `bad substitution`. Distinguish unset from empty by exit status instead:
  `if val=$(printenv "$var"); then …` (rc 1 = unset, rc 0 + empty = set-but-empty).
- `${PIPESTATUS[…]}` — bash-only; zsh spells it `pipestatus` (1-based) and leaves the
  uppercase name unset, so `rc=${PIPESTATUS[0]}` expands empty and a `${rc:-0}` default
  reads as success. This inverts rather than empties the result: the guard emits an
  affirmative *pass* for a command that failed. Never reach for it to keep a pipe —
  drop the pipeline instead, per the verdict-pipeline rule below.
- **Glob qualifiers** (`(N)`, `(.)`) — zsh-only, and when `bareglobqual` is off
  (verified off in an agent shell, zsh 5.9) they are *reparsed*, not ignored: `(N)`
  becomes a pattern group matching a literal `N`, so `*.md(N)` silently means "files
  ending `.mdN`". It then reports `no matches found` on a directory full of `.md`
  files, and — worse — matches the *wrong* files with status 0 once a `.mdN` exists.
  **Important:** Never let a composed command depend on a glob qualifier or on `nullglob`/`failglob`
  state; enumerate with `find … -print` fed through `while IFS= read -r`, which cannot
  conflate "nothing matched" with "pattern unsupported".
- **Lowercase `path` is a zsh special array tied to `PATH`.** In scripts and
  compound ad-hoc commands, never use it as a loop or script variable: one
  scalar assignment replaces the executable search path. Use role-specific names such as `doc_path`,
  `source_path`, or `target_path`. See [zsh special
  variables](zsh-special-path-variable.md).
- **A verdict that contradicts the output it summarizes indicts the guard, not the
  output.** Re-derive the status with a dialect-independent construct before believing
  a green whose own captured output reports a failure.

## Bash 3.2 Targeting

Target bash 3.2 for any hook or script that may run under the macOS
system bash (`/bin/bash`). Avoid bash-4+ builtins — `mapfile`/`readarray`,
associative arrays (`declare -A`), `${var^^}`/`${var,,}` case conversion,
negative array indices. Replace `mapfile -t arr < <(cmd)` with
`while IFS= read -r x; do …; done <<< "$(cmd)"`. Verify with
`/bin/bash script.sh` (3.2) before committing — `mapfile: command not found`
is the classic 4-only failure. Detect support for a flag or feature by running it against a known-good input and branching on the exit code — never by grepping the stderr wording.

Worked example:
[`2026-06-10_bash32-no-mapfile.md`](2026-06-10_bash32-no-mapfile.md).
