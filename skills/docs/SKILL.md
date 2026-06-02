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
  version: '2026.06.02-200532'
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

## Step 4: Spec / RFC Quality Gate

Applies ONLY when authoring or finalizing a **spec, RFC, design doc, ADR, or
plan** — not routine README/code-doc updates (those use Steps 1-3). Before
writing or delivering such a doc, enforce every gate below:

- **Frontmatter (machine-readable YAML):** include `title`, `type` (RFC | spec |
  ADR | plan), `status`, `author`, `created`, `last_updated`, `epic` (ticket
  URL), `reviewers` (list), `labels`, and `related` (list of `{title, path-or-url}`).
- **Diátaxis structure:** separate explanation (why — motivation, context,
  goals) from reference (what — interfaces, schemas) from guide (how — worked
  examples). Lead with a "How to read this doc" note naming the sections and
  what each reader type focuses on.
- **Diagram discipline:** open the guide section with ONE block/interaction
  diagram showing all major components and their contracts, then one focused
  detail diagram per major component in its own section. Never ship a single
  monolithic diagram.
- **Link hygiene:** resolve every referenced doc path on disk and verify every
  ticket/URL before writing. Mark any reference to a not-yet-created artifact as
  `TBD` explicitly — never leave a dead or speculative link unmarked.
- **No fabricated sizing:** omit effort/timeline estimates, or mark them `TBD`,
  unless the user supplied them.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn docs`).
