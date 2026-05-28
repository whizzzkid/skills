# Git Hooks

Wired through `lefthook.yml` at the repo root.

## scrub-staged.sh — identifier leakage guard

Pre-commit hook that blocks any staged diff containing:

- The case-insensitive resolved value of `$EMPLOYER` or `$GITHUB_ORG`
  from the current shell environment.
- Any PCRE regex listed in `.githooks/scrub-denylist.txt` (gitignored,
  one regex per line, `#` comments allowed).

Literal references `$EMPLOYER`, `${EMPLOYER}`, `$GITHUB_ORG`,
`${GITHUB_ORG}` in staged content are stripped before matching, so
documentation that names the env vars is allowed.

### Activation

The repo uses lefthook. After cloning:

```bash
mise exec -- lefthook install
```

### Adding patterns

Copy the example file and add machine-specific patterns:

```bash
cp .githooks/scrub-denylist.txt.example .githooks/scrub-denylist.txt
$EDITOR .githooks/scrub-denylist.txt
```

The file is gitignored — patterns never get committed.

### Bypass

Do not bypass with `--no-verify`. If the hook blocks a commit, replace
the offending identifier with a placeholder (`{owner}/{repo}`,
`<service>`, `$EMPLOYER`, etc.) and re-stage.
