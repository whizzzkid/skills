# Git Hooks

Wired through `lefthook.yml` at the repo root.

## check-prohibited.sh — prohibited-terms guard (files + commit messages)

Blocks any staged diff line **and** any commit message that matches a pattern in
the gitignored `.skillprohibit` file. Runs in two lefthook stages:

- `pre-commit` (no arg) — scans staged added diff lines.
- `commit-msg` (message file arg) — scans the commit message body.

`.skillprohibit` holds the real internal/vendor codenames, board prefixes,
hosts, and legacy names (one `grep -iE` pattern per line). It is gitignored, so
the term list never enters the repo — and neither does this hook embed any term.
Copy `.skillprohibit.example` → `.skillprohibit` and add your tokens to enable.

Rationale: file-level scrubbing misses commit messages, which are part of
history. Describing a scrub by naming the scrubbed token re-leaks it; describe
changes by category instead.

## check-ticket-refs.sh — internal ticket-ID guard

Pre-commit hook that blocks staged added lines containing an internal tracker
ticket key. It detects the generic ticket shape `[A-Z]{2,}-[0-9]+` and rejects
anything not on a small allowlist of public, standards-based tokens (`UTF-8`,
`ISO-8601`, `SHA-256`, `RFC-NNN`, `BOARD-NNN`, …).

No internal board name is embedded in the hook — embedding it would itself leak
the name. New internal boards are caught automatically. Replace any real ticket
key with the generic placeholder `BOARD-NUM`. If a genuine public standard trips
it, add that token to `ALLOW` in the hook.

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
