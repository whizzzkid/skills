# Agent Conventions

## Source of Truth

- **`AGENTS.md` is the single source of truth for all project conventions.**
- `CLAUDE.md` is a thin pointer that imports this file — it carries no rules
  of its own.
- Never edit `CLAUDE.md` directly. A request to "write to", "update", "add
  to", or "fix" `CLAUDE.md` means **edit `AGENTS.md`**.

## Repeatable-Error Prevention

- **Encode every hard check as a git commit hook.** When a mistake is caught
  that could recur mechanically, add a pre-commit hook in `.githooks/` and
  wire it into `lefthook.yml` — never rely on a written instruction alone.
- A soft fix (a rule in a `SKILL.md` or `AGENTS.md`) is necessary but not
  sufficient; pair it with a mechanical guard whenever the error is
  detectable from the staged diff.
- Document each hook in `.githooks/README.md`.

## Public Repo — No Internal References

This repository is **public**. Never write or commit any of the following in
**any** file — learnings, retros, references, docs, code, or commit messages:

- Internal or code-named projects, services, bots, or repos.
- Internal tracker / ticket IDs (board keys shaped `PREFIX-NNN`).
- Hard-coded user-land file paths (home dirs, worktree paths, any machine-local
  absolute path).
- Secrets, tokens, credentials, or other sensitive information.
- Employer / organization names as literals (use the env-var mechanism in
  Environment-Specific Identifiers).

**The goal of every learning is the principle and root cause** — phrased so it
improves a skill that is agnostic to the org, company, environment, or system it
runs against. A lesson keyed to a specific internal name teaches one case; the
generic mechanism teaches the class. Distill the principle; discard the identity.

When a concrete token is unavoidable for the lesson to be legible, anonymize it:

- Bot / reviewer → `{bot}` / `{reviewer}`; internal repo / project → `{repo}` /
  `{project}`; service → `{service}`.
- Internal ticket ID → `BOARD-NUM`.
- Employer / org path segment → `$EMPLOYER` / `$GITHUB_ORG` (resolved at run
  time; see Environment-Specific Identifiers).
- User-land path → repo-relative, or a generic placeholder (`/tmp/agent/…`,
  `~/<workdir>/…`).

Mechanical enforcement: `.githooks/scrub-staged.sh` (employer/org denylist) and
`.githooks/check-ticket-refs.sh` (ticket-shaped tokens). The remaining classes
above are the author's responsibility — scrub before staging.

## Repository Structure

- Skills live in `skills/<skill-name>/SKILL.md` — each skill has a `group:` frontmatter field indicating its logical group (`rituals`, `pull-request`, `tools`, `workflows`)
- Each skill is a self-contained directory with a single `SKILL.md` file
- Optional `scripts/` and `references/` subdirectories for supporting files

## Naming Rules

- Skill names: always prefixed with `wk-` (e.g., `wk-my-cool-skill`)
- Skill directories: `kebab-case` (e.g., `my-cool-skill`) — no prefix in directory name
- Definition file: always `SKILL.md` (uppercase)
- Scripts: `kebab-case.sh` with executable permissions

## SKILL.md Format

```yaml
---
name: wk-skill-name
description: When and why to use this skill
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
---
```

Required fields: `name`, `description`

## Adding a Skill

1. Create `skills/<skill-name>/SKILL.md` and set `group:` in frontmatter
2. Add YAML frontmatter with `name` and `description`
3. Write clear instructions in the markdown body
4. Update the skills table in `README.md`
5. Write `README.md` following the template in `skills/README.md`

## README Maintenance

Every skill directory MUST contain a `README.md` alongside its `SKILL.md`. The README follows
the per-skill format established in `skills/README.md` (name heading, purpose, invocation trigger,
key phases or rules, and integration points).

**Co-change rule:** When `SKILL.md` changes — description, invocation behavior, phases, hard rules,
or integration points — the corresponding `README.md` MUST be updated in the **same commit**.
No exceptions; a SKILL.md update without a README.md update is an incomplete commit.

**Rename/remove rule:** When a skill is renamed or removed, its `README.md` must be
renamed/deleted in the same commit as the `SKILL.md` change, and its row must be
removed from **both** index files (below) in that same commit.

**New-skill rule:** Every new skill ships with its `README.md` in the **same
commit** as the `SKILL.md` — never a follow-up. Confirm `skills/<name>/README.md`
exists (matching the `name:` field per the drift check below) and add a row to
**both** index files (below) in the same commit.

**Dual-index rule:** There are **two** skill index files and both MUST stay in
sync with the `skills/` tree:

- `skills/README.md` — canonical owned index (grouped tables, header skill/group
  counts). Link form: `` [`wk-<name>`](./<name>/README.md) ``.
- `README.md` — root landing-page mirror. Link form: `[<name>](skills/<name>/)`.

Update **both** whenever a skill is added, removed, renamed, has its `group:`
change, or has its one-line `description:` change materially. `_template/` is
the only directory excluded. The `check-readme-index` pre-commit hook
(`.githooks/check-readme-index.sh`) enforces this mechanically: it blocks any
commit where a `skills/<name>/` dir lacks a row in either index, or either index
carries an orphan row for a directory that no longer exists. `wk-skill` Step 6
writes both rows at add time.

**Drift check (pre-sharpen gate):** Before any `wk-sharpen` commit lands, verify the modified
`SKILL.md`'s `name:` frontmatter value matches the `# wk-*` heading in its `README.md`. If they
diverge, fail and fix before committing:

```bash
skill_name=$(grep '^name:' skills/<skill-name>/SKILL.md | awk '{print $2}')
readme_heading=$(grep '^# wk-' skills/<skill-name>/README.md | head -1 | sed 's/^# //')
[ "$skill_name" = "$readme_heading" ] || echo "DRIFT: $skill_name != $readme_heading"
```

## Cross-Skill Claims

Cross-skill prose (in any `README.md`, `SKILL.md`, or doc) must reflect what
the target skill **actually does** — not what is assumed from memory. Before
writing "`wk-foo` does X", grep the target skill:

```bash
grep -n "HARD RULE\|writes to\|destination" skills/<target>/SKILL.md
```

Memory-based assertions about other skills decay fast — verify, don't recall.
(Example caught in the field: READMEs claimed `wk-retro` writes to
`~/.claude/memory/`, but its narrative goes to
`$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>.md`; only distilled rules
reach memory.)

## Inter-Skill Links

In any markdown file inside this repo, an inline mention of another `wk-*`
skill must be a relative link to that skill's README:

```markdown
- Bad:  See `wk-retro` for the retro flow.
- Good: See [`wk-retro`](../retro/README.md) for the retro flow.
```

- Applies to all `skills/*/README.md` files, `skills/README.md`, and other
  top-level docs.
- Keep Mermaid `click` directives in sync with the inline links.
- Use `../<name>/README.md` from a sibling skill's README, `./<name>/README.md`
  from `skills/README.md`, and the full path from files outside `skills/`.
- Enforced mechanically by `.githooks/check-skill-links.sh`.

## WIP / Disabled Skills

When a skill is marked WIP (`status: wip`, `model-invocable: false`,
`user-invocable: false`):

- Add a `> ⚠️ Work in progress` banner at the top of both `SKILL.md` and
  `README.md`.
- List the concrete blockers under a `## Blockers` section in the README so a
  future session can pick it up cold.
- Re-enabling requires bumping CalVer and dropping the banner in the same commit.

## Guidelines

- Keep `SKILL.md` under 500 lines
- Write specific descriptions so agents activate the skill only when relevant
- Use `metadata.internal: true` for skills that should be hidden from discovery
- Skills are model-invocable by default — use `model-invocable: true` to
  explicitly enable, or `disable-model-invocation: true` to opt out.
  `disable-model-invocation: false` is a no-op and should not be used.

## Versioning

All skill versions use **CalVer** format: `YYYY.MM.DD-HHMMSS` (UTC).
Semver (`MAJOR.MINOR.PATCH`) is forbidden in this project.

Whenever a `metadata.version` field needs to be set or bumped, invoke
`wk-calver` to generate the correct UTC timestamp:

```bash
date -u '+%Y.%m.%d-%H%M%S'
```

This applies to all skills, including `_template`.

## Post-Change Hook

After adding or updating any skill, always run:

```bash
npx skills add . -g -y -a=claude
```

This reinstalls all skills globally for the agent. Never skip this step.

## Environment-Specific Identifiers

**HARD RULE: Never commit employer or organization names as literals.** This
repository is public and employer-agnostic. All employer/org references must be
dynamic, resolved from environment variables at runtime:

- **`$EMPLOYER`** — the user's current employer name (e.g. set in `~/.zshrc` or `~/.claude/profile.sh`)
- **`$GITHUB_ORG`** — the user's GitHub organization slug (already enforced by `wk-gh`)

Rules:
- Never write an employer name, org name, or company slug as a literal string in any `SKILL.md`, `README.md`, `AGENTS.md`, script, or reference file.
- Never commit learnings, notes, or reference files that contain a literal employer/org name. Scrub before committing: replace literals with `$EMPLOYER` or `$GITHUB_ORG`.
- Parameterize the employer/org **segment of a path** instead of dropping the path: `~/gitc/<employer>/` → `~/gitc/$EMPLOYER` (and the same for a `$GITHUB_ORG` segment). The agent resolves the env var at run time, so the path still works.
- Never embed an employer/org slug in MCP tool name patterns. Use a generic description instead (e.g. "search for a Google Calendar MCP tool via `ToolSearch`") — MCP tool names are environment-specific and cannot be predicted from a skill file.
- If you encounter a literal employer or org name anywhere in the tree during a sharpen/edit pass, replace it in the same commit.

Pre-commit check (add to `~/.claude/profile.sh`, substituting your employer token):

```bash
# Fail if any literal employer token lands in a commit
git diff --cached | grep -iE '\byour-employer-token-here\b' && echo "BLOCKED: literal employer name in diff"
```

## Workflow

- Always commit and push after every change to this project
