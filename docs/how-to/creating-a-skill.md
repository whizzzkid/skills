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
name: wk:your-skill-name
description: >-
  Describe when agents should activate this skill. Be specific about
  trigger phrases, use cases, and the problem it solves.
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
---
```

**Required fields:**

| Field | Description |
|-------|-------------|
| `name` | Unique identifier with `wk:` prefix, e.g. `wk:my-skill` |
| `description` | When and why to use this skill — agents match on this |

**Optional fields:**

| Field | Description |
|-------|-------------|
| `argument-hint` | Autocomplete hint for arguments (e.g., `[PR number or URL]`) |
| `allowed-tools` | Array of tools the skill can access at runtime |
| `model` | Per-provider model recommendations (nested map, see template) |
| `model-invocable` | Set `true` to explicitly enable model invocation |
| `disable-model-invocation` | Set `true` to opt out of model invocation |
| `license` | License identifier (e.g., `MIT`) |
| `metadata.author` | Skill author |
| `metadata.version` | Semantic version |
| `metadata.effort` | Complexity level: `low`, `medium`, or `high` |
| `metadata.internal` | Set `true` to hide from discovery |

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
npx skills check
```

This validates that your skill is discoverable and the frontmatter is correct.

## Tips

- Write descriptions that help agents decide when to activate — vague descriptions lead to false activations
- Prefer scripts over inline code in skill instructions to reduce token consumption
- Test with `npx skills add . -s wk:your-skill-name` to verify local installation
