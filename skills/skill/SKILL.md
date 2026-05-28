---
name: wk-skill
description: >-
  Scaffold a new wk-* skill from the canonical template. Use when creating a
  new skill from scratch — generates the directory, fills frontmatter, applies
  best practices, hooks into wk-calver / wk-learn, and verifies installation.
  Trigger phrases: "create a skill", "new skill", "bootstrap a skill",
  "scaffold a skill", "/wk-skill <name>".
argument-hint: '<skill-name> [description hint]'
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
  - "Bash(date:*)"
  - "Bash(mkdir:*)"
  - "Bash(test:*)"
  - "Bash(find:*)"
  - "Bash(grep:*)"
  - "Bash(npx:*)"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.05.28-203524'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Skill

Scaffold a new `wk-*` skill from the canonical template, pull in any relevant
field learnings, and wire up all infrastructure hooks.

## When to Use

- Creating a new skill from scratch
- Bootstrapping a skill directory before writing its body
- When `/wk-skill <name>` is invoked directly

**REQUIRED BACKGROUND:** Read `superpowers:writing-skills` before filling in
the skill body — the TDD RED-GREEN-REFACTOR cycle applies to all skill
authoring. This skill creates the scaffold only; the body comes after the RED
phase (baseline test without the skill).

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

Stop and tell the user to set `$WK_SKILLS_HOME` if missing.

Parse the argument:
- Strip a leading `wk-` prefix from the directory name (the `wk-` lives in
  the `name:` frontmatter field, not the directory).
- The skill `name:` field is always `wk-<name>`.
- If no argument is provided, ask the user for the skill name.

## Step 2: Guard against collisions

```bash
test -d "$WK_SKILLS_HOME/skills/<name>" && echo "EXISTS" || echo "CLEAR"
```

Stop if the directory already exists — do not overwrite an existing skill.
Suggest `wk-sharpen` if the user wants to improve an existing one.

## Step 3: Surface relevant learnings

Scan for unprocessed learnings that may inform the new skill's scope or
known pitfalls:

```bash
find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" \
  ! -name "*.learned.md" -type f 2>/dev/null | head -20
```

Also grep for the skill name / topic across existing learnings:

```bash
grep -rl "<name>" "$WK_SKILLS_HOME/learnings/" 2>/dev/null
```

Read any matches. Surface key insights as a bullet list before scaffolding —
these become the first draft of the "Common Mistakes" section.

## Step 4: Determine metadata

If description, model tier, effort, or group were not provided as arguments, ask:

1. **Description** (one sentence, "Use when…" form, ≤500 chars)
2. **Group** — pick the logical group this skill belongs to:
   - `rituals` — time-bounded routines: daily bookends, session wrap-ups, performance reviews
   - `pull-request` — anything in the PR lifecycle: create, review, resolve, update, break
   - `tools` — external tool integrations: CI, observability, VCS, containers, package managers
   - `workflows` — development process: commits, formatting, docs, testing, meta-skills
3. **Model tier** — pick based on task complexity:

   | Tier | When | Claude | OpenAI | Gemini |
   |------|------|--------|--------|--------|
   | `sonnet` | Most skills — structured, multi-step work | claude-sonnet-4-6 | gpt-4.1-mini | gemini-2.5-flash |
   | `opus` | Deep reasoning, adversarial review, batch distillation | claude-opus-4-7 | o3 | gemini-2.5-pro |
   | `haiku` | Single lookups, calver generation, trivial transforms | claude-haiku-4-5 | gpt-4.1-nano | gemini-2.5-flash-8b |

4. **Effort** — `low` (single action), `medium` (multi-step flow), `high`
   (long-running, many decisions)
5. **User-invocable** — `true` if the user should call it directly with `/`
6. **Model-invocable** — `true` if another skill or agent should auto-trigger it

## Step 5: Generate CalVer version

Invoke `wk-calver` to get the UTC timestamp for `metadata.version`.

```bash
date -u '+%Y.%m.%d-%H%M%S'
```

## Step 6: Scaffold the skill

```bash
mkdir -p "$WK_SKILLS_HOME/skills/<name>"
```

Write `$WK_SKILLS_HOME/skills/<name>/SKILL.md` with:
- Frontmatter filled in from Steps 4–5, including `group: <group>` before `metadata:`
- Skeleton body: `# <Title>`, `## When to Use`, `## Step 1`, `## Quick Reference`, `## Requirements`, `## Post-Completion`
- `## Post-Completion` always ends with:
  ```
  Invoke `wk-learn` with this skill's short name as the argument
  (e.g., `wk-learn <name>`).
  ```
- If Step 3 surfaced learnings, add a pre-filled `## Common Mistakes` section
  with those insights

**HARD RULE — MCP tools use wildcards, never employer-specific IDs.** When
populating `allowed-tools` with MCP connector entries, replace the org/tenant
segment with `*`:

```yaml
# Wrong — embeds an employer-specific identifier
allowed-tools:
  - mcp__claude_ai_Slack_AcmeCorp__slack_send_message

# Correct — wildcards the org segment
allowed-tools:
  - "mcp__claude_ai_Slack_*__slack_send_message"
```

This applies to all MCP tool patterns: `mcp__claude_ai_<Service>_*__<operation>`.
Quote wildcard entries so YAML parsers don't interpret `*` as a glob anchor.

**HARD RULE:** Write only the skeleton — no behavior instructions yet.
Writing the body before running the RED phase (testing baseline agent behavior
without the skill) violates the `superpowers:writing-skills` TDD contract.

**HARD RULE — skills live in `$WK_SKILLS_HOME`, never `~/.claude/skills/`.**
`~/.claude/skills/` is read-only — it is managed by the install step that
syncs from the skills repo. Direct writes there bypass change management,
versioning, and review.

- Always scaffold into `$WK_SKILLS_HOME/skills/<name>/`.
- If `$WK_SKILLS_HOME` is unset, stop and ask the user where the skills
  repo lives — do not default to the installed path.

**HARD RULE — model-invocation frontmatter.** Use `model-invocable: true`
to mark a skill as model-invocable. Never use `disable-model-invocation:
false` — it is a no-op (skills are model-invocable by default) and reads
as misleading dead config. To opt out, set `disable-model-invocation: true`.

**HARD RULE — sub-command state must define a deterministic fallback.**
Any sub-command (e.g., `/wk-foo:bar`) that reads session-scoped state
(active mode, active config, current context) must explicitly state the
behavior when that state is absent.

- Pick a default and document it in the skill body.
- Emit a one-line confirmation in the sub-command output naming the
  resolved state (`"compressing using mode: brief (default — no active
  mode)"`).
- Refusing or silently guessing are both wrong; the user cannot debug
  either.

## Step 7: Show the scaffold and prompt

Display the full scaffolded `SKILL.md` to the user. Then print:

> "Scaffold written to `skills/<name>/SKILL.md`.
>
> **Next steps (follow `superpowers:writing-skills`):**
> 1. RED — test a subagent on your scenario *without* the skill; document
>    exact rationalizations and failures.
> 2. GREEN — fill in the skill body to address those specific failures.
> 3. REFACTOR — identify new loopholes, add explicit counters, re-test.
>
> Run `/wk-skill --install` after writing the body to verify and commit."

## Step 8: Install and verify (run after body is written)

When the user has filled in the skill body and asks to install/verify:

```bash
cd "$WK_SKILLS_HOME" && npx skills add . -g -y -a=claude 2>&1 | tail -5
```

Must print `Done!`. If it prints `No skills found` or exits non-zero:
- Re-run from the repo root (`$WK_SKILLS_HOME`)
- Check that `name:` in frontmatter uses only letters, numbers, and hyphens

**HARD RULE — `allowed-tools` must match the body two-way.** Before
declaring the skill ready:

- Grep the skill body for every tool-call pattern (`Bash(`, `Read(`,
  `Edit(`, `WebFetch(`, `Skill(`, MCP tool names). Every match must
  appear in `allowed-tools`.
- Walk each `allowed-tools` entry in reverse — every entry must be
  exercised by a concrete step in the body. Remove orphaned entries.
- Missing entries fail silently at runtime. Orphaned entries grant
  unnecessary permissions and rot into stale config.

Confirm the skill appears in the registry:

```bash
npx skills list -a=claude 2>/dev/null | grep "wk-<name>"
```

## Step 9: Commit

Invoke `wk-commit` with message:

```
✨ feat(skills): add wk-<name> skill
```

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-skill <name>` | Full scaffold + metadata prompts |
| `/wk-skill <name> "description"` | Scaffold with pre-filled description |
| `/wk-skill --install` | Skip scaffold, run Steps 8–9 on current dir |

## Requirements

- `$WK_SKILLS_HOME` set to the skills repo root
- Write access to `$WK_SKILLS_HOME/skills/`
- `npx` available for install verification
- `superpowers:writing-skills` read before filling in the skill body

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn skill`).
