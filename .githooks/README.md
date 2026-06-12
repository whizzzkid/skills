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

## check-readme-index.sh — skill-index sync guard

Pre-commit hook that keeps both skill indexes in lockstep with the `skills/`
tree, enforcing AGENTS.md § README Maintenance "Root index rule". It runs only
when the staged set touches a skill's `SKILL.md` (added, modified, renamed, or
**deleted**) or either index file, then verifies:

- Every `skills/<name>/` directory (except `_template`) has a row in **both**
  the root [README.md](../README.md) (`[<name>](skills/<name>/)`) and the
  canonical [skills/README.md](../skills/README.md)
  (`` [`wk-<name>`](./<name>/README.md) ``).
- Neither index links to a skill directory that no longer exists (orphan row
  left behind by a rename or removal).

This closes the gap that `check-readme.sh` (sibling-README existence only) does
not cover: a new skill landing without an index row, or a removed skill leaving
a dangling row. [`wk-skill`](../skills/skill/README.md) Step 6 writes both rows
at add time; this hook enforces the invariant regardless of author.

## check-readme-sync.sh — README co-update guard

Pre-commit hook that blocks any commit staging a `skills/<name>/SKILL.md`
without its sibling `skills/<name>/README.md` in the **same** commit. This
keeps each README (and its `**Version:**` line) from drifting away from the
`SKILL.md` it documents.

Distinct from `check-readme.sh`, which only requires the README to **exist**:
this hook requires it to be **co-staged** on every SKILL.md change.
[`wk-sharpen`](../skills/sharpen/README.md) Step 7 bumps the README version and
syncs changed steps/diagram before committing; this hook enforces it regardless
of author.

## check-relative-paths.sh — machine-absolute path guard

Pre-commit hook that blocks machine-absolute or home-rooted paths in committed
content. Scans only **added** lines of the staged diff, so it catches new leaks
without forcing a sweep of pre-existing references.

- Blocked in an added line: `/Users/<...>`, `/home/<...>`, `/root/<...>`, and
  bare `~/<...>`.
- Allowed: `$HOME`, `${HOME}`, `$WK_SKILLS_HOME`, `$CLAUDE_PROJECT_DIR`, any
  other `$VAR` / `${VAR}` env-var-rooted path, and repo-relative paths.
- Exempt: `.githooks/*` (these hooks and their docs define the patterns
  literally) and binary/lock files.

Root-cause guard for absolute home paths (e.g. `/Users/<name>/...`) leaking a
username into committed content and git history.

## check-usernames.sh — human @-mention guard

Pre-commit hook that blocks a human `@username` (reviewer / teammate login) in
committed prose. Scans added lines outside fenced code blocks; flags a bare
`@handle` unless it is an allowlisted generic token, a version ref (`@v4`), a
file/email/scope (`@x.json`, `user@host`, `@org/pkg`), or in the ALLOW list in
the hook (placeholders like `@reviewer`/`@user`, CSS at-rules, decorators).

- Fix a flagged mention by anonymizing: reviewer login -> `{reviewer}`,
  teammate -> `{user}`, PR author -> `{author}`.
- A genuine non-human at-token gets added to the hook's `ALLOW` list.
- Exempt: `.githooks/*` (the hooks list tokens literally) and binary/lock files.

## check-pr-numbers.sh — internal PR/issue number guard

Pre-commit hook that blocks committing internal PR / issue / run numbers in
markdown. Scans added lines of `*.md`:

- Path forms (`pulls/NN`, `issues/NN`, `runs/NN`) are blocked everywhere.
- Bare `#NN` / `PR #NN` are blocked only outside fenced code blocks, so CSS hex
  colours (`#39ff14`, `#222`) inside ```css fences pass.
- Fix by genericizing: a bare PR number -> `#NNN`, `repo#<n>` -> `repo#NNN`,
  `pulls/<n>` -> `pulls/{n}`. A real hex colour belongs inside a code fence.
- Exempt: `.githooks/*`.

Pairs with the wk-learn / wk-retro scrub rules (which strip PR numbers at
authoring time); this hook is the mechanical backstop.

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

## check-learning-filenames.sh — learning filename format guard

Pre-commit hook that blocks any staged `learnings/skills/<skill>/*.md`
whose basename does not match `YYYY-MM-DD_<kebab-name>.learned.md`:

- Date prefix at the start, underscore separator before the name.
- Lowercase kebab name (`a-z`, `0-9`, hyphens).
- `.learned.md` suffix — distilled. A plain `.md` is unprocessed and must be
  distilled (and renamed) before commit.

Enforces the convention used across the learnings corpus so batch-mode
[`wk-sharpen`](../skills/sharpen/README.md) can rely on the `.learned.md`
rename as the sole processed-state marker.

## check-retro-filenames.sh — retrospect filename format guard

Pre-commit hook that blocks any staged `learnings/retrospect/*.md` whose
basename does not match `YYYY-MM-DD_<kebab-name>[.learned].md`:

- Date prefix at the start, underscore separator before the slug.
- Lowercase kebab slug (`a-z`, `0-9`, hyphens), e.g. `session-1`.
- Plain `.md` is an unprocessed session (write-once); `.learned.md` is distilled.
- Legacy per-day files (`YYYY-MM-DD.md`, no slug) are grandfathered.

[`wk-retro`](../skills/retro/README.md) writes one file per session so each
retrospect is write-once — distilled and renamed to `.learned.md` by batch-mode
[`wk-sharpen`](../skills/sharpen/README.md), exactly like a learning file.

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
