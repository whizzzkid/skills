---
name: wk:skill-name
description: >-
  Describe when this skill should activate. Be specific — agents use this
  to decide whether to apply the skill. Include trigger phrases and use cases.
# Hint shown in autocomplete when user types /skill-name
argument-hint: '[optional arguments hint for autocomplete]'
# Restrict which tools this skill can access at runtime
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
# Claude Code model: sonnet | opus
# High tier (complex reasoning): opus
# Low tier (procedural tasks): sonnet
model: sonnet
# effort: low | medium | high
effort: medium
# Explicitly enable model invocation (skills are model-invocable by default)
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  internal: true
  # Cross-platform model recommendations
  # High tier: o3, gemini-2.5-pro, llama-4-maverick, k2, qwen3-235b, composer-2
  # Low tier: gpt-4.1-mini, gemini-2.5-flash, llama-4-scout, k2, qwen3-30b, composer-1.5
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Skill Name

Brief overview of what this skill does and why it exists.

## When to Use

- Scenario 1 where this skill applies
- Scenario 2 where this skill applies

## Instructions

### Step 1: Do the first thing

Explain what the agent should do and why.

### Step 2: Do the next thing

Continue with clear, actionable instructions.

## Examples

```
Example input or usage scenario
```

Expected behavior or output.

## References

- Link to relevant documentation or resources

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
mkdir -p "$WK_SKILLS_HOME/learnings/skills/_template"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/_template/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:_template
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

> "📝 Learning captured: `_template/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
