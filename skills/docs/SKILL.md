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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Docs

Update docs affected by code changes; bootstrap a docs structure when none exists.

## File Access Rules

**HARD RULE:** Write and Edit tools may ONLY target files under the project's docs root (check for `docs/`,
`documentation/`, `doc/`, or `site/` — use whichever exists). Never write or edit files outside the docs root.
Read, Glob, and Grep may access any path (read-only).

## Claim-Grounding Gate

Apply to every doc, README, announcement, and PR-body accuracy pass — not only Step 4 artifacts.

**HARD RULE — ground capability verbs, not just figures.** A pass scoped to citable numbers ships false
capability claims untouched: a claim with no number is never examined.

- Extract every **capability verb** (runs, executes, validates, enforces, blocks, prevents, detects, learns,
  remembers); require each to name the file or symbol implementing it. No implementing code path → downgrade
  to roadmap language or cut it.
- Audit title, subtitle, and one-line summary first: they compress hardest and are least likely to carry a
  citation.
- **Regeneration is a transform, not a rewrite.** Rebuilding an artifact from a source file adds no claim
  absent from that source.
- **A failure claim is an observation, not a property — record where it was seen.** Write "fails on `<env>`
  with `<symptom>`; unverified elsewhere", never the universal "is broken". Require a second environment to
  agree before the claim earns declarative voice or drives config (excluding a check from required gates,
  relaxing acceptance criteria).

## Step 1: Check for Affected Docs

Scan plans (`docs/plans/`), specs (`docs/specs/`), ADRs (`docs/adr/`), tutorials (`docs/tutorials/`), and
examples (`docs/examples/`):

```bash
find docs/ -name '*.md' 2>/dev/null | head -50
```

Update only docs the changes made inaccurate — leave correct docs alone.

- **New configurable surface → mandatory doc, unprompted.** A new YAML config field, env var, JSON output
  field, or CLI flag → write or update the user-facing doc (README, repository guide) in the same session; do
  not wait for the user to ask. New config-schema section → also add a `docs/specs/` entry (context, decision,
  data flow, config reference) per Step 4's quality gate.
- **Record an invariant at its point of enforcement, not only in an ADR.** A decision constraining a specific
  list, config key, or build input → state it as a short note beside that thing (in the file an agent edits to
  violate it, or the repo's agent-instructions file); let the ADR carry the reasoning. Keep the note to the
  invariant plus an ADR pointer — never duplicate the rationale. The note adds to the ADR, never replaces it.

## Step 2: Bootstrap if Missing

No `docs/` folder → create one with a minimal `docs/README.md` index:

```bash
mkdir -p docs/{plans,specs,adr,tutorials,examples}
```

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

`docs/README.md` exists → update its index when adding or removing docs: list every doc, leave no stale entry.

## Step 4: Spec / RFC Quality Gate

Apply ONLY when authoring or finalizing a **spec, RFC, design doc, ADR, or plan** — routine README/code-doc
updates use Steps 1-3. Enforce every gate before writing or delivering:

- **Arch review is mandatory on this class of doc**, per [`wk-arch-review`](../arch-review/README.md)'s
  contract: run it once on the finished draft, before delivery. Read its record when one covers this artifact;
  otherwise the authoring gate (this step, or `wk-plan` when the plan owns the doc) dispatches it. Never deliver
  an arch-bearing doc with no recorded verdict.
- **Frontmatter (machine-readable YAML):** `title`, `type` (RFC | spec | ADR | plan), `status`, `author`,
  `created`, `last_updated`, `epic` (ticket URL), `reviewers` (list), `labels`, `related` (list of
  `{title, path-or-url}`).
- **Diátaxis structure:** separate explanation (why — motivation, context, goals) from reference (what —
  interfaces, schemas) from guide (how — worked examples). Lead with a "How to read this doc" note naming the
  sections and what each reader type focuses on.
- **Diagram discipline:** open the guide section with ONE block/interaction diagram of all major components
  and their contracts, then one focused detail diagram per major component in its own section. Never ship a
  single monolithic diagram.
- **Link hygiene:** resolve every referenced doc path on disk and verify every ticket/URL before writing. Mark
  any reference to a not-yet-created artifact `TBD` explicitly — never leave a dead or speculative link
  unmarked.
- **No fabricated sizing:** omit effort/timeline estimates, or mark them `TBD`, unless the user supplied them.
- **Important — cross-section consistency:** after editing any concept, grep the whole doc for its core terms
  and review every hit for consistent tense, qualifier, and implementation status (a risk-table row or summary
  stating the old default is a top bot-review flag).
  - **Reversing a verdict → sweep by the subject's identifier, not the retracted wording.** Every phrase the
    old verdict justified is in scope — acceptance criteria, summary tables, downstream config the doc drove.

## Post-Completion

Invoke `wk-learn docs`.
