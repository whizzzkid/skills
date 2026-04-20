---
name: wk:docs
description: >-
  Check for and update documentation affected by code changes. Use when making
  code changes, adding features, modifying APIs, or when docs may be stale.
  Bootstraps a docs structure if the project doesn't have one.
allowed-tools:
  - "Bash(find docs/:*)"
  - "Bash(mkdir docs/:*)"
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - "Bash(mkdir -p:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Docs

Check for and update documentation affected by code changes. Bootstraps a
docs structure if the project doesn't have one.

## File Access Rules

**HARD RULE: Write and Edit tools may ONLY target files under `docs/` in
the project root. Never write or edit files outside of `docs/`.**

Read, Glob, and Grep may access any path (read-only) to understand code changes.

## Step 1: Check for Affected Docs

Scan for documentation that relates to the current code changes. Look in:

- Plans (`docs/plans/`)
- Specs (`docs/specs/`)
- ADRs (`docs/adr/`)
- Tutorials (`docs/*/tutorials/`)
- How-to guides (`docs/*/how-to/`)
- Explanation docs (`docs/*/explanation/`)
- Reference docs (`docs/*/reference/`)

```bash
find docs/ -name '*.md' 2>/dev/null | head -50
```

For each doc found, check if the current changes affect it. If so, update it
to reflect the new state. Focus on accuracy — don't rewrite docs that are
still correct.

## Step 2: Bootstrap if Missing

If the project has no `docs/` folder, create one:

```bash
mkdir -p docs/{plans,specs,adr,tutorials,examples}
```

Create a minimal `docs/README.md` index:

```markdown
# Documentation

| Section | Description |
|---------|-------------|
| [Plans](plans/) | Implementation plans |
| [Specs](specs/) | Design specifications |
| [ADR](adr/) | Architecture decision records |
| [Tutorials](tutorials/) | Step-by-step guides |
| [Examples](examples/) | Example configurations |
```

## Step 3: Keep Index Current

If `docs/README.md` exists, update its index when adding or removing docs.
Ensure every doc file is listed and no stale entries remain.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Code changes made | Scan for affected docs, update as needed |
| No docs folder | Bootstrap `docs/` structure |
| New doc added/removed | Update `docs/README.md` index |

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/docs"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/docs/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:docs
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `docs/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
