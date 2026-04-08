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
