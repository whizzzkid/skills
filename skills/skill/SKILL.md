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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Skill

Create a new `wk-*` skill end to end — directory, frontmatter, full body, README, field learnings, and infrastructure
hooks. `/wk-skill <name> "description"` pre-fills the Step 4 description; `/wk-skill --install` → skip authoring, run
Steps 8–9 on the current dir. Requires `$WK_SKILLS_HOME` (skills repo root) with write access to its `skills/`, and
`npx` for install verification.

**Implement the full skill when asked.** One pass → frontmatter + complete, runnable body + README. Do not stop at a
skeleton. Do not gate delivery on any test-first ceremony — write, install, commit. Apply a RED-GREEN-REFACTOR
hardening pass (`superpowers:writing-skills`) only on explicit user request.

## Steps 1–2: Check environment and guard against collisions

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
test -d "$WK_SKILLS_HOME/skills/<name>" && echo "EXISTS" || echo "CLEAR"
```

1. `MISSING` → stop, tell user to set `$WK_SKILLS_HOME`.
2. Strip leading `wk-` from the directory name (`wk-` lives in `name:` frontmatter, not the directory); `name:` is
   always `wk-<name>`. No argument → ask user for the skill name.
3. `EXISTS` → stop, do not overwrite. Suggest `wk-sharpen` to improve an existing skill.

## Step 3: Surface relevant learnings

Scan unprocessed learnings, then grep the skill name / topic across all learnings:

```bash
find "$WK_SKILLS_HOME/learnings/skills" -name "*.md" \
  ! -name "*.learned.md" -type f 2>/dev/null | head -20
grep -rl "<name>" "$WK_SKILLS_HOME/learnings/" 2>/dev/null
```

Read matches → surface key insights as a bullet list before writing → these seed the "Common Mistakes" section.

## Steps 4–5: Determine metadata and version

Ask for anything not provided as arguments, then invoke `wk-calver` (Step 5) for the UTC `metadata.version` timestamp
(`date -u '+%Y.%m.%d-%H%M%S'`):

1. **Description** — one sentence, "Use when…" form, ≤500 chars
2. **Group** — `rituals` (time-bounded routines: daily bookends, session wrap-ups, performance reviews);
   `pull-request` (PR lifecycle: create, review, resolve, update, break); `tools` (external tool integrations: CI,
   observability, VCS, containers, package managers); `workflows` (development process: commits, formatting, docs,
   testing, meta-skills)
3. **Model tier** — by task complexity: `haiku` single lookups/trivial transforms; `sonnet` most skills; `opus` deep
   reasoning, adversarial review, batch distillation. Per-vendor IDs: [model tiers](references/model-tiers.md).
4. **Effort** — `low`, `medium`, `high`, `xhigh`, or `max`; increase only when task complexity warrants it
5. **User-invocable** — `true` if the user calls it directly with `/`; **Model-invocable** — `true` if another skill
   or agent auto-triggers it

## Step 6: Write the skill

```bash
mkdir -p "$WK_SKILLS_HOME/skills/<name>"
```

Write `$WK_SKILLS_HOME/skills/<name>/SKILL.md` with the **full body**, not a skeleton:

- Frontmatter from Steps 4–5, including `group: <group>` before `metadata:`.
- Complete body: `# <Title>`, `## When to Use`, numbered `## Step N` sections with concrete imperative instructions
  and runnable commands, `## Post-Completion`. No Quick Reference table or Requirements section: state a
  needed tool or credential in the step that uses it.
- Every Step carries real behavior — commands, checks, decision rules — derived from the description and Step 3
  learnings. Never leave `<!-- DESIGN NOTES -->` or "RED phase not yet run" placeholders unless the user requested a
  scaffold-only pass.
- `## Post-Completion` always ends with: ``Invoke `wk-learn <name>`.`` — `<name>` is the unprefixed skill dir name.
- Step 3 surfaced learnings → add a `## Common Mistakes` section with those insights.

Write the sibling `README.md` in the **same commit** (AGENTS.md README co-change rule), per the format in
`skills/README.md`: `# wk-<name>` heading (matching `name:`), purpose, trigger, key phases/rules, integration points.
**Linkify every `wk-*` mention in the README from the first draft** — even an illustrative or placeholder
`wk-<name>`: write `[wk-<name>](../<name>/README.md)` or drop the backticks (plain `wk-<name>`). A bare backticked
`` `wk-foo` `` trips the `check-skill-links` pre-commit hook. The skill's own name in the `#` heading is exempt.

**HARD RULE — sync BOTH skill indexes in the same commit.** A new skill is not done until it has a row in **both**
index files. No "when in scope" exemption — every published skill (all except `_template/`) appears in both
(`check-readme-index` blocks the commit otherwise):

- `skills/README.md` (canonical owned index) — add a row to the matching group table:
  `` | [`wk-<name>`](./<name>/README.md) | <purpose> | <invocation> | ``. Add a new group section if `group:` has no
  table yet. Bump the skill-count and group-count in the header line.
- `README.md` (root landing-page mirror) — add a row to the matching group:
  `` | [<name>](skills/<name>/) | <description> | ``.

**HARD RULE — MCP tools use wildcards, never employer-specific IDs.** In `allowed-tools`, replace the org/tenant
segment with `*` and quote the entry so YAML parsers don't read `*` as a glob anchor:
`"mcp__claude_ai_Slack_*__slack_send_message"`, never `mcp__claude_ai_Slack_AcmeCorp__slack_send_message`. Applies
to all MCP tool patterns: `mcp__claude_ai_<Service>_*__<operation>`.

**HARD RULE — skills live in `$WK_SKILLS_HOME`, never `$HOME/.claude/skills/`.** `$HOME/.claude/skills/` is
read-only — managed by the install step syncing from the skills repo. Always scaffold into
`$WK_SKILLS_HOME/skills/<name>/`. `$WK_SKILLS_HOME` unset → stop, ask where the skills repo lives. Do not default to
the installed path.

**HARD RULE — model-invocation frontmatter.** Mark model-invocable with `model-invocable: true`. Never use
`disable-model-invocation: false` — a no-op (skills are model-invocable by default). To opt out, set
`disable-model-invocation: true`.

**Conditional rules** — apply [conditional rules](references/conditional-rules.md) when the skill has a
sub-command reading session-scoped state, replaces/supersedes/deprecates existing skills, or a skill is removed,
renamed, or has a material `group:`/`description:` change.

## Steps 7–8: Present, install and verify

Display the completed `SKILL.md` and `README.md` (Step 7), then continue directly to Step 8 and Step 9. Do not wait for
the user to "fill in the body"; it is already written.

```bash
cd "$WK_SKILLS_HOME" && npx skills add . -g -y --agent claude-code 2>&1 | tail -5
```

Must print `Done!`. Prints `No skills found` or exits non-zero → re-run from the repo root (`$WK_SKILLS_HOME`); check
`name:` frontmatter uses only letters, numbers, hyphens.

**HARD RULE — `allowed-tools` must match the body two-way.** Before declaring ready:

- Grep the body for every tool-call pattern (`Bash(`, `Read(`, `Edit(`, `WebFetch(`, `Skill(`, MCP tool names).
  Every match must appear in `allowed-tools` (missing entries fail silently at runtime).
- Walk each `allowed-tools` entry in reverse — every entry must be exercised by a concrete step. Remove orphaned
  entries.
- A write/mutating command the skill exists to run (`gh pr merge`, `git push`, `gh pr edit`) needs its own granular
  `Bash(<cmd>:*)` grant — bare `Bash` alone leaves the auto-mode classifier gating it per-command. Grant it in the
  skill's OWN `allowed-tools`, never by self-editing global `$HOME/.claude/settings.json`.

Confirm the skill appears in the registry:
```bash
npx skills list --agent claude-code 2>/dev/null | grep "wk-<name>"
```

## Step 9: Commit

Invoke `wk-commit` with `SKILL.md` and `README.md` staged together, message `✨ feat(skills): add wk-<name> skill`.

## Post-Completion

Invoke `wk-learn skill`.
