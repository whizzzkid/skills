---
name: wk-learn
description: >-
  Post-completion learning capture for any wk-* skill. Call at the end of a
  skill run to reflect on what happened and write a structured learning file
  for later distillation via wk-sharpen. Pass the calling skill's short name
  as the argument (e.g., `wk-learn pr-review`).
argument-hint: '<skill-name>  (e.g., pr-review, commit, workflow)'
allowed-tools:
  - Bash
  - Write
  - "Bash(mkdir -p:*)"
  - "Bash(test -n:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.01-073258'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Learn

Capture what happened during a skill run and write a structured learning file
for later distillation. Called at the end of any `wk-*` skill run.

The argument is the **calling skill's short name** (e.g., `pr-review`,
`commit`, `workflow`). If omitted, use `unknown`.

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, tell the user:

> "`$WK_SKILLS_HOME` is not set. Add `export WK_SKILLS_HOME=/path/to/skills`
> to your shell profile and restart your terminal."

**Stop here if the variable is missing.**

## Step 2: Reflect through 4 lenses

Review what happened during the calling skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections, API
   failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge cases
   not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs should
   know about

If **all four lenses are empty** (routine execution, nothing notable), skip
writing — not every run produces a learning.

## Step 3: Write the learning file

Set `SKILL_NAME` to the argument passed (e.g., `pr-review`). Then:

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME"
```

Write to `$WK_SKILLS_HOME/learnings/skills/$SKILL_NAME/<YYYY-MM-DD>_<slug>.md`:

```markdown
---
skill: wk-<SKILL_NAME>
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2–4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

## Step 4: Signal for distillation

After writing, output:

> "📝 Learning captured: `<SKILL_NAME>/<date>_<slug>.md` — distill with
> `wk-sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk-sharpen`.
