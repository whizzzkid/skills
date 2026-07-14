---
skill: wk-sitrep
date: 2026-07-14
type: correction
severity: high
---

`start` wrote live.md with a novel nested-`<div>` block that broke the 3-column layout, and announced the page as ready without ever loading it in a browser — user had to point out it was broken before a fix happened. This is a repeat failure mode (per user: "you break the layout every day").

**What happened:** Stage 4 introduced a nested unclassed `<div>` (grouping a meeting list) inside a `.sitrep-col`, deviating from the flat `<span class="st-item">` pattern used everywhere else in the file. The nested div collapsed the column boundary in the browser's HTML parser, so every subsequent `.st-item` span rendered as a direct flex child of `.sitrep-row` instead of nested inside `.sitrep-col` — single-column, narrow-wrapped, broken layout. The skill's own Stage 5/rendering-contract text says to verify in a browser before finishing, but the run went straight to "Live page ready" messaging without opening Playwright or checking the DOM.

**Root cause:** Two compounding gaps: (1) freelancing a new HTML shape (nested div) instead of reusing the exact pattern already proven to render correctly in the file being edited, and (2) treating "wrote the file + opened via `open` shell command" as equivalent to "verified render" — `open` just launches a browser tab, it doesn't confirm the DOM structure. The skill's Stage 5 announces readiness immediately after `open`, with no mandatory Playwright screenshot/DOM check gating that announcement.

**Suggested fix:** In wk-sitrep Stage 4/5, add a hard gate: before announcing "Live page ready," take a Playwright screenshot (or DOM query) of the freshly-written live.md and confirm the 3-column structure actually rendered (e.g., assert 3 `.sitrep-col` elements are present and non-empty) — mirroring wk-silverbullet's own Step 6 hard rule, which wk-sitrep currently only references in prose rather than enforcing as a blocking step. Also: never introduce a new HTML tag/nesting shape when editing a live.md — copy the exact working pattern from the file's own history/prior content instead of composing a new one from the general SilverBullet skill guidance.
