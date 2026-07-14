---
class: principle
skill: wk-sitrep
severity: high
---

# Verify the render before announcing the live page

**Rule:** Never announce "Live page ready" until a Playwright DOM check confirms
the layout actually rendered — assert 3 non-empty `.sitrep-col` elements. Opening
the URL (`open`) launches a tab; it does not confirm DOM structure. Root cause of
the recurring "breaks layout daily" failure: (1) a soft prose reference to
"verify in browser" that runs skipped it, and (2) freelancing a new HTML shape
(nested unclassed `<div>` to group items) instead of reusing the file's proven
flat `<span class="st-item">` pattern — the nested div collapses the flex column
boundary into a single narrow column.

**Why:** A referenced/soft verification step gets skipped under time pressure. A
repeat failure of an already-covered rule → escalate to a structural hard gate
that blocks the announcement, not another prose reminder.

**Where:** `SKILL.md` Stage 5 (hard-gate the announcement on a `browser_evaluate`
assertion) and the rendering contract (reuse the flat span pattern; never
introduce a new tag/nesting shape). Mechanism owned by wk-silverbullet Step 6.
