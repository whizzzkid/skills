# Rendering Contract

## SilverBullet integration

- Invoke [`wk-silverbullet`](../../silverbullet/README.md) for layout mechanics. It
  owns HTML-block blank-line rules, span-checkbox pattern, onclick handler,
  `window.client` API, `space-style` CSS, force-reload. This skill owns content
  selection.
- SilverBullet parses inline hashtags in link text → escape every `#` as `\#`,
  use full PR/issue titles (`repo\#N: commit-style title`), omit items with no
  canonical URL.

## Layout structure

- `live.md` is an HTML flexbox 3-column layout, not a Markdown table. Both
  `start` and `end` write frontmatter + `# Live — {DATE}` + one
  `<div class="sitrep-row">` containing three `<div class="sitrep-col">`.
- Actionable items use `<span class="st-item">` with a nested
  `<span class="st-cb" data-t="tN" data-done="false" onclick="HANDLER">`.
- `data-t` is unique and sequential per page (`t1`…`tN`).
- Auto-action items already done at generation start `data-done="true"`; nested
  sub-items use `class="st-item st-nested"`.

## Terminal state rule

**Mark done only what is terminal.** An auto-action leaving an artifact the
user must still act on (unsubmitted draft, unsent reply) renders its launch
done but stays open work — re-query and re-surface it every run until the
artifact is terminal.

## Nesting constraints

Group items only via the flat `st-item`/`st-nested` span pattern already in the
file. **Never freelance a new tag or nesting shape**; only a documented classed
`<div>` (the standup copy block) may nest inside `.sitrep-col`, and never with a
blank line before or after it — a blank line anywhere in a column body ends that
column's HTML block and ejects the rest full-width below the row, at any nesting
depth.

## Non-actionable content

Non-actionable content (meeting lines, headers, standup block) is plain text
or inline markdown.

## Priority/urgency sorting

Sort by priority/severity, staleness, due date, then undated. Lead with 🔴
overdue/ASAP, 🟡 due ≤3 days, or 🟢 later/no hard date; append `⏳ {N}d`
after 7 days pending. Format due dates as `**📅 YYYY-MM-DD**`.

## Style

Keep CSS/Lua in `$EMPLOYER/sitrep-style.md`; never regenerate it daily. After
style edits, force reload and verify before finishing.
