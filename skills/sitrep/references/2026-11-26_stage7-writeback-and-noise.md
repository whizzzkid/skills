---
class: principle
skill: wk-sitrep
date: 2026-11-26
---

# Write post-publish artifacts back to the page; prune noise before writing

- **Rule (write-back):** Any stage that runs after the page is committed and creates something the user must act on
  must patch that artifact back onto the page as an open item, re-run the render gate, and commit and push again.
  Stage 7's review drafts land in Needs attention now, group 1.
- **Rule (attention section):** col2 opens with one checklist of what must be cleared today: drafts created this
  run, older pending drafts, and items blocking others or due today. Each artifact has one home on the page.
- **Rule (noise):** Stage 3 runs a fixed filter table (duplicates, stacked urgency glyphs, handled, not the user's,
  FYI, empty status lines, lapsed deadlines, carry-over idle 21+ days, stale account notices, unreadable claims).
  It registers every drop in the dismissed registry and records the counts in Meta.
- **Why:**
  - Stage 7 ran after Stage 6's commit, and its render step only replaced the Auto-Actions placeholder with a done
    launch line, so the drafts it created never appeared as open work. A ticked launch reads as finished.
  - On a mostly carried-over page the item count only ever grows. One live page held about 230 items. Many were the
    same PR listed in two or three sections, lines with two or three stacked urgency glyphs (re-prefixed on each
    carry), items a peer owned or the user had already answered, and items idle for 3 to 8 weeks.
- **Where:** `SKILL.md` Stage 3 (prune), Stage 4 (Needs attention now HARD RULE), Stage 7 (write-back);
  [`needs-attention.md`](needs-attention.md), [`noise-filters.md`](noise-filters.md),
  [`auto-review.md`](auto-review.md) § Render, [`rendering-contract.md`](rendering-contract.md) (one urgency glyph).
- **Extends:** an uncommitted fold already in the tree that added a pending-review-drafts section. It is folded into
  groups 1–2 of the attention section, not shipped as a competing section.
