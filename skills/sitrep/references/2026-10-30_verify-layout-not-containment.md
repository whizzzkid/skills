---
class: principle
skill: wk-sitrep
severity: high
---

# Verify layout geometry, not just containment

**Rule** — the pre-announce render gate asserts sibling geometry: exactly three non-empty `.sitrep-row > .sitrep-col`
direct children, zero `.sitrep-col .sitrep-col`, and distinct, strictly increasing left edges; then a screenshot.
Non-actionable lines inside a column are checkbox-less `st-item st-info` spans, and the checkbox clause exempts only
`st-info`. A gate clause that rejects canonical markup is fixed, never satisfied by reshaping content.

**Why** — a page whose columns 2 and 3 were children of column 1 passed every clause. `closest('.sitrep-col')` and
scoped-vs-global counts stay true when a column is nested in a sibling, so a containment gate cannot fail on that
defect. The trigger: the "zero `.st-item` without `.st-cb`" clause contradicted the canonical template (which shows
checkbox-less `st-item` info lines), so info lines were rewritten as raw text ending in `<br>`; reverting them to
spans restored the layout. The parser mechanism behind the dropped column close was not read — recorded as
unverified; the rule does not depend on it, because the geometry gate catches the symptom whatever the cause. Not a
re-violation: the installed containment gate fired as specified; its specification had a gap (→ new clause, not an
escalation).

**Where** — `SKILL.md` Stage 5 (geometry, scoped checkbox clause, screenshot, fix-the-clause rule), Stage 4 (*Info
lines are spans too*), Stage 1 (same-day re-run regathers or says the gather was reused);
`references/rendering-contract.md` (Layout structure, Non-actionable content). Generic form:
`wk-silverbullet` `references/rendering-rules.md` verification loop and Common Mistakes.
