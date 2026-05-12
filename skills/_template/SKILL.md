---
name: wk-skill-name
description: >-
  Describe when this skill should activate. Be specific — agents use this
  to decide whether to apply the skill. Include trigger phrases and use cases.
argument-hint: '[optional arguments hint for autocomplete]'
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - Write
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.08-183557'
  internal: true
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Skill Name

Brief overview of what this skill does and why it exists.

## When to Use

- Scenario 1 where this skill applies
- Scenario 2 where this skill applies

## Style Rules

- **Bullets over prose.** Default to bulleted lists; use a paragraph only when the rule cannot split into discrete imperatives.
- **Imperative voice.** Each bullet starts with a verb: "Run", "Verify", "Reject". No "you should" / "we recommend".
- **No essays.** A section that runs past four bullets either splits into named sub-sections or trims to the load-bearing rules.

## Step 1: Do the first thing

Explain what the agent should do and why.

## Step 2: Do the next thing

Continue with clear, actionable instructions.

**HARD RULE:** State the rule in one sentence. Follow with a brief explanation of the
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
