---
name: wk-skill
description: >-
  Create a new wk-* skill from scratch — generates the directory, fills
  frontmatter, writes the full skill body and README, applies best practices,
  hooks into wk-calver / wk-learn, and verifies installation. Trigger phrases:
  "create a skill", "new skill", "bootstrap a skill", "scaffold a skill",
  "/wk-skill <name>".
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
  version: '2026.05.29-070346'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Skill

Create a new `wk-*` skill end to end — directory, frontmatter, full body,
README, field learnings, and infrastructure hooks.

## When to Use

- Creating a new skill from scratch
- When `/wk-skill <name>` is invoked directly

**Implement the full skill when asked.** Generate frontmatter plus a complete,
runnable body and its README in one pass. Do not stop at a skeleton. Do not
gate delivery on any test-first ceremony — write the skill, install it, commit
it. Apply a RED-GREEN-REFACTOR hardening pass only if the user explicitly asks
for one.

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

Read any matches. Surface key insights as a bullet list before writing the
skill — these become the first draft of the "Common Mistakes" section.

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

## Step 6: Write the skill

```bash
mkdir -p "$WK_SKILLS_HOME/skills/<name>"
```

Write `$WK_SKILLS_HOME/skills/<name>/SKILL.md` with the **full body** — not a
skeleton:
- Frontmatter filled in from Steps 4–5, including `group: <group>` before `metadata:`
- Complete body: `# <Title>`, `## When to Use`, numbered `## Step N` sections
  with concrete imperative instructions and runnable commands, `## Quick
  Reference`, `## Requirements`, `## Post-Completion`.
- Every Step carries real behavior — commands, checks, decision rules — derived
  from the user's description and Step 3 learnings. Never leave
  `<!-- DESIGN NOTES -->` or "RED phase not yet run" placeholders unless the
  user explicitly requested a scaffold-only pass.
- `## Post-Completion` always ends with:
  ```
  Invoke `wk-learn` with this skill's short name as the argument
  (e.g., `wk-learn <name>`).
  ```
- If Step 3 surfaced learnings, add a `## Common Mistakes` section with those
  insights.

Write the sibling `$WK_SKILLS_HOME/skills/<name>/README.md` in the **same
commit** (AGENTS.md README co-change rule). Follow the per-skill format in
`skills/README.md`: `# wk-<name>` heading (matching the `name:` field), purpose,
trigger, key phases/rules, and integration points. Add a row to
`skills/README.md`'s table when the skill is in scope for the top-level index.

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

## Step 7: Present the skill

Display the completed `SKILL.md` and `README.md`, then continue directly to
Step 8 (install) and Step 9 (commit) — the skill is ready to ship. Do not stop
and wait for the user to "fill in the body"; the body is already written.

## Step 8: Install and verify

After writing the body and README (Step 6), install and verify:

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

Invoke `wk-commit` with the `SKILL.md` and `README.md` staged together:

```
✨ feat(skills): add wk-<name> skill
```

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-skill <name>` | Full implementation + metadata prompts |
| `/wk-skill <name> "description"` | Implement with pre-filled description |
| `/wk-skill --install` | Skip authoring, run Steps 8–9 on current dir |

## Requirements

- `$WK_SKILLS_HOME` set to the skills repo root
- Write access to `$WK_SKILLS_HOME/skills/`
- `npx` available for install verification
- `superpowers:writing-skills` (only for an explicitly-requested RED-GREEN-REFACTOR pass)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn skill`).
