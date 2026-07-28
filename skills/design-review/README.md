# wk-design-review

**Version:** `2026.07.28-171039`

Principal-level UX / product-design review. Critically evaluates design changes —
visual, interaction, information architecture, accessibility, and the design
language itself — and returns severity-ranked findings. Judges against principle,
not taste: every finding names the heuristic it violates and a concrete fix.

## Trigger

- `/wk-design-review <path-or-url>` — review a design doc, file, or rendered URL.
- `/wk-design-review consult <pr-or-path>` — Consult Mode: return structured
  findings only (used by other skills/agents).
- `/wk-design-review write <topic>` — draft or critique a design spec.
- Auto-invoked when a consulting skill (notably [`wk-pr-review`](../pr-review/README.md))
  detects a diff touching design surfaces.

## What it does

1. **Gather** — reads the changed design surfaces (components, CSS, tokens,
   `design.md`), renders live UI via the Playwright MCP, and establishes the
   existing design language as the baseline.
2. **Evaluate** — walks consistency, visual hierarchy, accessibility (WCAG 2.2 AA),
   interaction/feedback, state coverage, content clarity, responsiveness, and
   cognitive load.
3. **Hunt anti-patterns** — hardcoded values, contrast failures, missing states,
   modal overuse, non-semantic markup, and dark patterns (always a blocker).
4. **Rank & write** — findings most-severe first (`blocker` · `major` · `minor` ·
   `nit`), each with location, principle violated, user harm, and a fix.
5. **Deliver** — presents to the user, or returns structured findings in Consult
   Mode. Never auto-applies UI changes.

## Scope boundary

Owns UX / visual / interaction / IA / accessibility design.
[`wk-arch-review`](../arch-review/README.md) owns system architecture (SPOFs, data
flow, topology). A change can trigger both; each reviews its own layer.

## Integration

- [`wk-pr-review`](../pr-review/README.md) consults this skill (Consult Mode) when a
  PR diff touches design surfaces and folds its findings into the review.
- For charts and shareable artifacts, defers to the `dataviz` and `artifact-design`
  skills for deeper visual iteration.
- Emits a field learning via [`wk-learn`](../learn/README.md) on completion.
