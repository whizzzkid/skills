# wk-skill

> Scaffold a new wk-* skill from the canonical template with full infrastructure wiring.

**Version:** `2026.07.28-171108`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-skill <name>`, "create a skill", "new skill", "bootstrap a skill" |
| Model-invocable | automatic: when another skill needs a companion skill created |

## How It Works

```mermaid
flowchart TD
    A[Check $WK_SKILLS_HOME] --> B[Guard: skill already exists?]
    B -->|exists| Z[Stop — suggest wk-sharpen]
    B -->|clear| C[Scan learnings for topic-relevant insights]
    C --> D[Determine metadata: group, model tier, effort, invocability]
    D --> E[Generate CalVer version via wk-calver]
    E --> F[mkdir + write SKILL.md skeleton]
    F --> G[Display scaffold + TDD prompt]
    G --> H{User fills in skill body}
    H --> I[npx skills add . -g -y --agent claude-code]
    I --> J{Done! printed?}
    J -->|yes| K[Confirm registry entry]
    J -->|no| L[Re-run from repo root / check frontmatter]
    K --> M[wk-commit: feat - add wk-name skill]
    click Z href "https://github.com/whizzzkid/skills/blob/main/skills/sharpen/README.md" _blank
    click E href "https://github.com/whizzzkid/skills/blob/main/skills/calver/README.md" _blank
    click M href "https://github.com/whizzzkid/skills/blob/main/skills/commit/README.md" _blank
```

## Noteworthy

- **Full implementation in one pass** — the skill writes complete, runnable body + README, not
  a skeleton. A RED-GREEN-REFACTOR hardening pass runs only when the user explicitly asks for one.
- **HARD RULE: sync both indexes** — a new skill is not done until it has a row in **both**
  `README.md` (root mirror) and `skills/README.md` (canonical), in the same commit. The
  `check-readme-index` pre-commit hook blocks the commit otherwise; removal/rename must clear
  both rows too.
- The `wk-` prefix lives in the `name:` frontmatter field only — the **directory name** strips
  it (e.g., skill name `wk-<name>` → directory `skills/<name>/`).
- Step 3 surfaces unprocessed learnings relevant to the new skill's topic, which become the
  first draft of a `## Common Mistakes` section if matches are found.
- **Three Claude-safe model tiers** with OpenAI mappings: `haiku` → `gpt-5.6-luna`,
  `sonnet` → `gpt-5.6-terra`, and `opus` → `gpt-5.6-sol`.
- `$WK_SKILLS_HOME` must be set; the skill stops immediately if missing — it does not guess
  or fall back to `$PWD`.
- `## Post-Completion` section with `wk-learn <name>` call is always added to the skeleton —
  every skill is expected to capture its own learnings.
