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
  version: "2026.07.28-171108"
  model:
    openai: gpt-5.6-terra
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
- `/wk-skill <name>` invoked directly

**Implement the full skill when asked.** One pass → frontmatter + complete,
runnable body + README. Do not stop at a skeleton. Do not gate delivery on any
test-first ceremony — write, install, commit. Apply a RED-GREEN-REFACTOR
hardening pass only on explicit user request.

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If missing → stop, tell user to set `$WK_SKILLS_HOME`.

Parse the argument:
- Strip leading `wk-` from directory name (`wk-` lives in `name:` frontmatter, not the directory).
- `name:` field is always `wk-<name>`.
- No argument → ask user for the skill name.

## Step 2: Guard against collisions

```bash
test -d "$WK_SKILLS_HOME/skills/<name>" && echo "EXISTS" || echo "CLEAR"
```

Directory exists → stop, do not overwrite. Suggest `wk-sharpen` to improve an
existing skill.

## Step 3: Surface relevant learnings

Scan unprocessed learnings that may inform scope or known pitfalls:

```bash
find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" \
  ! -name "*.learned.md" -type f 2>/dev/null | head -20
```

Grep the skill name / topic across existing learnings:

```bash
grep -rl "<name>" "$WK_SKILLS_HOME/learnings/" 2>/dev/null
```

Read matches → surface key insights as a bullet list before writing → these
seed the "Common Mistakes" section.

## Step 4: Determine metadata

If description, model tier, effort, or group were not provided as arguments, ask:

1. **Description** — one sentence, "Use when…" form, ≤500 chars
2. **Group** — logical group:
   - `rituals` — time-bounded routines: daily bookends, session wrap-ups, performance reviews
   - `pull-request` — PR lifecycle: create, review, resolve, update, break
   - `tools` — external tool integrations: CI, observability, VCS, containers, package managers
   - `workflows` — development process: commits, formatting, docs, testing, meta-skills
3. **Model tier** — by task complexity:

   | Tier | When | Claude Code | OpenAI | Gemini |
   |------|------|-------------|--------|--------|
   | `haiku` | Single lookups, CalVer, trivial transforms | `haiku` | `gpt-5.6-luna` | `gemini-2.5-flash-8b` |
   | `sonnet` | Most skills — structured, multi-step work | `sonnet` | `gpt-5.6-terra` | `gemini-2.5-flash` |
   | `opus` | Deep reasoning, adversarial review, batch distillation | `opus` | `gpt-5.6-sol` | `gemini-2.5-pro` |

4. **Effort** — `low`, `medium`, `high`, `xhigh`, or `max`; increase only when task complexity warrants it
5. **User-invocable** — `true` if the user calls it directly with `/`
6. **Model-invocable** — `true` if another skill or agent auto-triggers it

## Step 5: Generate CalVer version

Invoke `wk-calver` for the UTC `metadata.version` timestamp:

```bash
date -u '+%Y.%m.%d-%H%M%S'
```

## Step 6: Write the skill

```bash
mkdir -p "$WK_SKILLS_HOME/skills/<name>"
```

Write `$WK_SKILLS_HOME/skills/<name>/SKILL.md` with the **full body**, not a
skeleton:
- Frontmatter from Steps 4–5, including `group: <group>` before `metadata:`.
- Complete body: `# <Title>`, `## When to Use`, numbered `## Step N` sections
  with concrete imperative instructions and runnable commands, `## Quick
  Reference`, `## Requirements`, `## Post-Completion`.
- Every Step carries real behavior — commands, checks, decision rules — derived
  from the description and Step 3 learnings. Never leave `<!-- DESIGN NOTES -->`
  or "RED phase not yet run" placeholders unless the user requested a
  scaffold-only pass.
- `## Post-Completion` always ends with:
  ```
  Invoke `wk-learn` with this skill's short name as the argument
  (e.g., `wk-learn <name>`).
  ```
- Step 3 surfaced learnings → add a `## Common Mistakes` section with those insights.

Write the sibling `$WK_SKILLS_HOME/skills/<name>/README.md` in the **same
commit** (AGENTS.md README co-change rule). Follow the per-skill format in
`skills/README.md`: `# wk-<name>` heading (matching `name:`), purpose, trigger,
key phases/rules, integration points.

- **Linkify every `wk-*` mention in the README from the first draft** — even an
  illustrative or placeholder `wk-<name>`. Write `[wk-<name>](../<name>/README.md)`,
  or drop the backticks (plain `wk-<name>`). A bare backticked `` `wk-foo` ``
  trips the `check-skill-links` pre-commit hook → forces a re-commit. The
  skill's own name in the `#` heading is exempt.

**HARD RULE — sync BOTH skill indexes in the same commit.** A new skill is not
done until it has a row in **both** index files. No "when in scope" exemption —
every published skill (all except `_template/`) appears in both:

- `skills/README.md` (canonical owned index) — add a row to the matching group
  table: `` | [`wk-<name>`](./<name>/README.md) | <purpose> | <invocation> | ``.
  Add a new group section if `group:` has no table yet. Bump the skill-count
  and group-count in the header line.
- `README.md` (root landing-page mirror) — add a row to the matching group:
  `` | [<name>](skills/<name>/) | <description> | ``.

The `check-readme-index` pre-commit hook blocks the commit if either row is
missing → add both up front.

**Removal / rename obligation.** This skill only *adds*. On removal or rename,
the same commit MUST delete or update its row in **both** indexes (and header
counts) — `check-readme-index` flags an orphan row pointing at a deleted
directory. A material `group:` or `description:` change likewise updates both
indexes.

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

Applies to all MCP tool patterns: `mcp__claude_ai_<Service>_*__<operation>`.
Quote wildcard entries so YAML parsers don't read `*` as a glob anchor.

**HARD RULE — skills live in `$WK_SKILLS_HOME`, never `$HOME/.claude/skills/`.**
`$HOME/.claude/skills/` is read-only — managed by the install step syncing from the
skills repo. Direct writes there bypass change management, versioning, review.

- Always scaffold into `$WK_SKILLS_HOME/skills/<name>/`.
- `$WK_SKILLS_HOME` unset → stop, ask where the skills repo lives. Do not
  default to the installed path.

**HARD RULE — model-invocation frontmatter.** Mark model-invocable with
`model-invocable: true`. Never use `disable-model-invocation: false` — a no-op
(skills are model-invocable by default), reads as misleading dead config. To
opt out, set `disable-model-invocation: true`.

**HARD RULE — sub-command state must define a deterministic fallback.** Any
sub-command (e.g., `/wk-foo:bar`) reading session-scoped state (active mode,
active config, current context) must state the behavior when that state is
absent.

- Pick a default, document it in the body.
- Emit a one-line confirmation naming the resolved state (`"compressing using
  mode: brief (default — no active mode)"`).
- Refusing or silently guessing are both wrong — the user cannot debug either.

**HARD RULE — supersede parity audit.** When the user frames the new skill as
replacing/superseding/deprecating existing skills ("replaces X", "instead of
X", "deprecate X once this ships"), audit each named skill for feature parity
before declaring done.

- Read each superseded skill's `SKILL.md`, extract its stage/feature list.
- Confirm the new skill covers each feature, or record an explicit, intentional
  exclusion in the body — implicit features surface one-by-one across later
  runs, each forcing a follow-up sharpen pass.
- Keep the deprecated file when the new skill links to it as a spec source —
  deprecation marks it superseded; deletion orphans the reference.

## Step 7: Present the skill

Display the completed `SKILL.md` and `README.md` → continue directly to Step 8
(install) and Step 9 (commit). The skill is ready to ship. Do not wait for the
user to "fill in the body"; it is already written.

## Step 8: Install and verify

After writing the body and README (Step 6):

```bash
cd "$WK_SKILLS_HOME" && npx skills add . -g -y --agent claude-code 2>&1 | tail -5
```

Must print `Done!`. If it prints `No skills found` or exits non-zero:
- Re-run from the repo root (`$WK_SKILLS_HOME`).
- Check `name:` frontmatter uses only letters, numbers, hyphens.

**HARD RULE — `allowed-tools` must match the body two-way.** Before declaring
ready:

- Grep the body for every tool-call pattern (`Bash(`, `Read(`, `Edit(`,
  `WebFetch(`, `Skill(`, MCP tool names). Every match must appear in
  `allowed-tools`.
- Walk each `allowed-tools` entry in reverse — every entry must be exercised by
  a concrete step. Remove orphaned entries.
- Missing entries fail silently at runtime. Orphaned entries grant unnecessary
  permissions and rot into stale config.
- A write/mutating command the skill exists to run (`gh pr merge`, `git push`,
  `gh pr edit`) needs its own granular `Bash(<cmd>:*)` grant — bare `Bash` alone
  leaves the auto-mode classifier gating it per-command, forcing a redundant
  confirmation even when invoking the skill IS the authorization. Grant it in the
  skill's OWN `allowed-tools`, never by self-editing global
  `$HOME/.claude/settings.json` (that edit is itself classifier-blocked and wrongly
  widens global scope).

Confirm the skill appears in the registry:

```bash
npx skills list --agent claude-code 2>/dev/null | grep "wk-<name>"
```

## Step 9: Commit

Invoke `wk-commit` with `SKILL.md` and `README.md` staged together:

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
