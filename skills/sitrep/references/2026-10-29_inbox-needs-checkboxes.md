---
class: principle
---

# Actionable means checkbox — link lists included

**Rule** — every item the user must act on is its own `st-item` with an `st-cb` and `data-t`, including each link
in a link list. Checkbox-less text is for non-actionable content only. Action sections sit directly under ASAP, one
short line per item, and the Stage 5 render check asserts zero `.st-item` without an `.st-cb` before announcing.

**Why** — the rendering contract already required a checkbox on every actionable item, yet a new list section was
built as checkbox-less bullets: a list of links read as presentation, not as items. A guessed shape (checkbox-less
children whose parent carries state) was then written into the contract, compounding the error, and nothing fixed
where such a section sits or how long a line may be — so the user had to ask three times. Re-violation of an
installed rule → escalated one rung (baseline → `**Important:**`) and folded into `SKILL.md` Stage 4, with a
mechanical render assertion so the miss is caught before announcing.

**Where** — `SKILL.md` → Stage 4 (*Important: actionable means checkbox*, *HARD RULE — GitHub Inbox*) and Stage 5
render check; `references/rendering-contract.md` → Nesting constraints.
