# Improve Mode — full procedure

Extended detail for `/wk-sharpen improve [scope]`. The inline section in `SKILL.md`
carries the trigger, the scope argument, and the phased-approval gate; this file carries
the procedure and the remaining hard rules. Anything stated in `SKILL.md` wins.

## Hard rules

- **No information loss.** Remove a rule only if it is provably duplicated elsewhere or
  superseded by a stricter rule. (The suite-wide form of this gate lives in `SKILL.md`
  Step 7.5: never drop a HARD RULE, error code, or failure-mode explanation.)
- **Phased approval required.** Auto mode does not short-circuit this — also stated inline
  in `SKILL.md`, because auto mode is exactly the context that would skip this file.
- **Capture insights.** External research surfacing a useful pattern → add it to the
  overfit-categories table or as a new `wk-sharpen` rule.

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
