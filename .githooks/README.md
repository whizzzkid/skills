# Git Hooks

Wired through `lefthook.yml` at the repo root.

## check-learnings-dirs.sh — learnings directory naming guard

Pre-commit hook that blocks any staged path under a `wk-`-prefixed
directory in `learnings/skills/`. Directories there must match the
unprefixed skill directory name in `skills/` — the `wk-` prefix lives
only in the SKILL.md `name:` field.

Root-cause guard for the [`wk-learn`](../skills/learn/README.md) bug
where passing the full skill name (e.g.
[`wk-workflow`](../skills/workflow/README.md)) created
`learnings/skills/wk-workflow/` instead of `learnings/skills/workflow/`.
The skill itself strips the prefix in Step 3; this hook enforces the
invariant regardless of how the file was created.

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
