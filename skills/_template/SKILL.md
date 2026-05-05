---
name: wk-skill-name
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
  - Write
# Claude Code model: sonnet | opus
# High tier (complex reasoning): opus
# Low tier (procedural tasks): sonnet
model: sonnet
# effort: low | medium | high
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.01-224941'
  model:
    openai: gpt-4.1-mini       # low tier: gpt-4.1-mini | high tier: o3
    google: gemini-2.5-flash   # low tier: gemini-2.5-flash | high tier: gemini-2.5-pro
    meta: llama-4-scout        # low tier: llama-4-scout | high tier: llama-4-maverick
    kimi: k2
    qwen: qwen3-30b            # low tier: qwen3-30b | high tier: qwen3-235b
    cursor: composer-2
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

## HARD RULE: Example rule name

State the rule in one sentence. Follow with a brief explanation of the
failure mode it prevents and how to comply.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-skill-name` | Full flow description |
| `/wk-skill-name <arg>` | Variant behavior |

## Requirements

- Any tools, credentials, or context the skill needs

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn skill-name`).
