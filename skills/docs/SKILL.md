---
name: wk:docs
description: >-
  Check for and update documentation affected by code changes. Use when making
  code changes, adding features, modifying APIs, or when docs may be stale.
  Bootstraps a docs structure if the project doesn't have one.
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - AskUserQuestion
model: sonnet
effort: low
disable-model-invocation: false
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
