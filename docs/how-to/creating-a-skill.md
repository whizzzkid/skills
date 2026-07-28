# Creating a Skill

## Prerequisites

- This repository cloned locally
- Familiarity with the [Agent Skills spec](https://github.com/vercel-labs/skills)

## Steps

### 1. Create the skill directory

```bash
cp -r skills/_template skills/your-skill-name
```

Use `kebab-case` for the directory name.

### 2. Edit the SKILL.md frontmatter

```yaml
---
name: wk-your-skill-name
description: >-
  Describe when agents should activate this skill. Be specific about
  trigger phrases, use cases, and the problem it solves.
model: sonnet
effort: medium
license: MIT
metadata:
  author: whizzzkid
  version: 'YYYY.MM.DD-HHMMSS'  # CalVer, generated via wk-calver
  model:
    openai: gpt-5.6-terra
---
```

**Required fields:**

| Field | Description |
|-------|-------------|
| `name` | Unique identifier with `wk-` prefix, e.g. `wk-<name>` |
| `description` | When and why to use this skill — agents match on this |

**Optional fields:**

| Field | Description |
|-------|-------------|
| `argument-hint` | Autocomplete hint for arguments (e.g., `[PR number or URL]`) |
| `allowed-tools` | Array of tools the skill can access at runtime |
| `model` | Claude Code model alias: `haiku`, `sonnet`, or `opus` |
| `effort` | Claude Code effort: `low`, `medium`, `high`, `xhigh`, or `max` |
| `model-invocable` | Set `true` to explicitly enable model invocation |
| `disable-model-invocation` | Set `true` to opt out of model invocation |
| `license` | License identifier (e.g., `MIT`) |
| `metadata.author` | Skill author |
| `metadata.version` | UTC CalVer `YYYY.MM.DD-HHMMSS`; generate with [`wk-calver`]; semver forbidden |
| `metadata.model.openai` | OpenAI provider recommendation aligned with the top-level Claude tier |
| `metadata.internal` | Set `true` to hide from discovery |

[`wk-calver`]: ../../skills/calver/README.md

Keep the top-level `model` value Claude-native. Never replace it with an
OpenAI model ID; Claude Code rejects unsupported model annotations. Use this
provider mapping instead:

| Claude tier | OpenAI provider model |
|-------------|-----------------------|
| `haiku` | `gpt-5.6-luna` |
| `sonnet` | `gpt-5.6-terra` |
| `opus` | `gpt-5.6-sol` |

Codex discovers skills from `name` and `description`. The OpenAI value is a
custom routing hint for provider-aware launchers or subagent dispatch; it does
not replace the active Codex model by itself.

### 3. Write the skill body

The markdown body after the frontmatter is the skill's instructions. Structure it with:

- **When to Use** — Scenarios where the skill applies
- **Instructions** — Step-by-step agent actions
- **Examples** — Concrete usage scenarios
- **References** — Links to supporting docs

Keep the total file under 500 lines.

### 4. Add supporting files (optional)

```
skills/your-skill-name/
  SKILL.md
  scripts/       # Bash scripts the skill can invoke
  references/    # Supporting documentation
```

### 5. Update the README

Add your skill to the table in the root `README.md`:

```markdown
| your-skill-name | Brief description of what it does |
```

### 6. Test locally

```bash
npx skills add . --list
bats .githooks/test-model-routing.bats
```

These commands validate discovery and cross-provider model alignment.

## Authoring Quality Checklist

Audit your skill against these rules before opening a PR. Each one
catches a class of failure that has bitten skills in the past.

### `allowed-tools` discipline

Every entry in `allowed-tools` must correspond to a documented step in
the skill body that **calls that specific tool**. Speculative entries
grant unnecessary permissions (least-privilege violation) and confuse
reviewers about the skill's actual surface area.

Before publishing, walk the body and tick off each tool: "where does
this tool get called?" If you cannot point to a concrete step, remove
the entry.

Common false positives:
- `Edit` listed because the skill discusses "edit loops" — but the
  loop is in-line text editing, not the `Edit` tool.
- `Bash` left over from an earlier draft after the actual command was
  replaced by a structured tool.
- `Write` listed for sub-commands that only print output, never persist.

### Sub-command state fallback

Any sub-command that reads session state (an active mode, an active
config, the current context) must explicitly define what happens when
that state has not been set. Leaving it undefined forces the executing
agent to either:

1. Guess a default silently — undocumented behavior, irreproducible
2. Refuse — unhelpful when there is an obvious safe default

State the fallback in the skill text, with a confirmation line so the
user knows the default kicked in. Example:

> If no mode is active when `<sub-command>` is invoked, default to
> `<safe-mode>` and state it: `No mode active — using <safe-mode>.`

### Activation/deactivation symmetry

If the skill has activation triggers (slash command, natural language),
it must have matching deactivation triggers. Document both. A skill
that turns on without an off switch is a one-way door.

### Hard boundaries documented up-front

If the skill must never compress / never auto-fix / never act under
specific conditions (security, irreversible operations, user
clarifications), state those boundaries near the top of the body —
before any procedure that an agent might apply to a boundary case.

## Tips

- Write descriptions that help agents decide when to activate — vague descriptions lead to false activations
- Prefer scripts over inline code in skill instructions to reduce token consumption
- Test with `npx skills add . -s wk-your-skill-name` to verify local installation
