# How scope-guard decides "outside the repo"

1. Resolve the repo root via `git -C <cwd> rev-parse --show-toplevel`.
2. Tokenize the command quote-aware (`shlex`), so a quoted string stays ONE
   token — prose inside quotes cannot synthesize a path argument. A genuinely
   quoted root (`find "/etc"`) still unwraps and blocks. Unbalanced quotes fall
   back to a whitespace split (fail closed, never skip the check). Tokens are
   inspected as written and never shell-expanded, so a `$VAR`-rooted or
   command-substituted root is judged as the literal text `$VAR/…` — not an
   absolute path, so no comparison happens.
3. Split the tokens into command segments at shell separators and keep only
   segments that are themselves in-scope searches. Emit only each segment's
   **path operands**, resolved under that tool's own grammar:
   - A grep-family tool's first positional is the *pattern*, not a path — and it
     is absent entirely when `-e`/`-f` supplies the pattern. So a pattern
     carrying path-shaped text (a scrub check grepping *for* absolute-path
     shapes) is never charged as a search root.
   - `find`/`fd` path operands precede the first expression flag, so `-name <x>`
     values are not roots.
   - An unrelated segment's arguments are not search roots at all.
   - **A preceding `cd`/`pushd` target IS charged** against the next in-scope
     search — it moves the *effective* root, so `cd <outside> && grep -r x .`
     blocks even though the search names only `.`.
4. Strip any trailing shell separator (`;&|)`) from each candidate token, then
   normalize it (`os.path.normpath`, no existence required).
5. A path is "outside" when its normalized form does not sit under the repo
   root. Relative paths resolve against `cwd` and are treated as inside.
6. `python3` unavailable → fall back to scanning every whitespace token of the
   whole command (noisier, still closed; never fails open).
