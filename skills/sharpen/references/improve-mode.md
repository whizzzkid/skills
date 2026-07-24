# Improve Mode — full procedure

Extended detail for `/wk-sharpen improve [scope]`. The inline section in `SKILL.md`
carries the trigger, the scope argument, and the hard rules; this file carries the
procedure. Hard rules in `SKILL.md` win.

## Inventory

- Set `[scope]` to omitted / `all`, `<skill-name>`, or a glob pattern.
- Inventory every skill in scope.
- Build a per-skill map of hard rules, phases/steps, recurring sections, and cross-skill references.

## Audit

- Audit for:
  - duplicate or overlapping instructions
  - overfit residue
  - bloated sections
  - cross-skill duplication
  - stale or contradictory references
  - missing structure
- Optionally research best-practice patterns that survive overfit scrutiny.
- Consolidate findings by skill and cross-cutting theme.
- Rank by leverage:
  - **High** — clear win with no information loss
  - **Low** — nitpick or style preference

## Phased proposal

- Present phased proposals for suite-scale changes.
  - **Phase A** — extract shared boilerplate to referenced fragments
  - **Phase B** — per-skill deduplication and bloat trimming
  - **Phase C** — cross-skill consolidation
  - **Phase D** — apply external best-practice insights that survived review
- Wait for explicit user approval per phase.

## Apply

- Apply approved edits with the single-mode audit.
- Bump each skill's `metadata.version`.
- Commit per skill or phase, then push once at the end.
