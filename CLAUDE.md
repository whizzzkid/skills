@[AGENTS.MD](./AGENTS.md)

# Project-Specific HARD RULES

These rules supplement `AGENTS.md`. They exist because the user has had
to call them out more than once.

## 1. Every new skill ships with a `README.md` in the same commit

`AGENTS.md` already mandates this — but I have shipped at least one
skill (`wk-team-hud`) with a `SKILL.md` and no `README.md`. **Never
again.** Before declaring a new-skill PR or commit ready:

- Confirm `skills/<name>/README.md` exists and matches the SKILL.md
  `name:` field per the drift check in `AGENTS.md`.
- Add a row to `skills/README.md`'s skill table if the skill is in
  scope for the top-level index.

## 2. Verify behavioral claims about other skills before writing them

Cross-skill prose (in any `README.md`, `SKILL.md`, or doc) must reflect
what the target skill **actually does** — not what I assume from
memory. Before writing "`wk-foo` does X", grep the target skill:

```bash
grep -n "HARD RULE\|writes to\|destination" skills/<target>/SKILL.md
```

Concrete example caught by the user: multiple READMEs claimed
`wk-retro` writes to `~/.claude/memory/`. The skill's own SKILL.md says
the **narrative** goes to `$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>.md`
and only **distilled rules** (when any surface) go to memory. Memory-
based assertions about other skills decay fast — verify, don't recall.

## 3. Inline references to other skills must be relative markdown links

In any markdown file inside this repo, an inline mention of another
`wk-*` skill must be a relative link to that skill's README:

```markdown
- Bad:  See `wk-retro` for the retro flow.
- Good: See [`wk-retro`](../retro/README.md) for the retro flow.
```

This applies to:

- All `skills/*/README.md` files (inter-skill prose, "Noteworthy" bullets).
- `skills/README.md` and other top-level docs.
- Mermaid `click` directives already exist for many flows; keep them in
  sync with the inline links.

Use `../<name>/README.md` from within a sibling skill's README,
`./<name>/README.md` from `skills/README.md`, and the full path from
files outside `skills/`.

## 4. Don't lose track of WIP / disabled skills

When a skill is marked WIP (`status: wip`, `model-invocable: false`,
`user-invocable: false`):

- Add a `> ⚠️ Work in progress` banner at the top of both `SKILL.md`
  and `README.md`.
- List the concrete blockers under a `## Blockers` (or equivalent)
  section in the README so a future session can pick it up cold.
- Re-enabling requires bumping CalVer and dropping the banner in the
  same commit.
