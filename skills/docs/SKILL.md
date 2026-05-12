---
name: wk-docs
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
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.05.08-182819'
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

**HARD RULE:** Write and Edit tools may ONLY target files under the project's
docs root (check for `docs/`, `documentation/`, `doc/`, or `site/` — use whichever exists).
Never write or edit files outside the docs root.

Read, Glob, and Grep may access any path (read-only) to understand code changes.

## Step 1: Check for Affected Docs

Scan for documentation that relates to the current code changes. Look in:

- Plans (`docs/plans/`)
- Specs (`docs/specs/`)
- ADRs (`docs/adr/`)
- Tutorials (`docs/tutorials/`)
- Examples (`docs/examples/`)

```bash
find docs/ -name '*.md' 2>/dev/null | head -50
```

For each doc found, check if the current changes affect it. If so, update it
to reflect the new state. Update only docs the changes have made inaccurate — leave correct docs alone.

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

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn docs`).
