---
skill: wk-sitrep
date: 2026-06-08
type: correction
severity: high
---

`live.md` uses an HTML div-based 3-column format with `data-done` span checkboxes — not the markdown table with ⬜/✅ glyphs described in the skill spec.

**What happened:** The `wk-sitrep` SKILL.md specifies a markdown table with `<br>`-joined cells and ⬜/✅ glyphs. In practice, this format was replaced with an HTML flexbox layout because markdown tables cannot contain interactive checkboxes. The current production format is materially different from what the skill spec describes.

**Root cause:** Markdown tables do not support SilverBullet's native `- [ ]` task widgets. The HTML div approach allows interactive `<span onclick>` checkboxes that persist state to the file via `window.client.space.writePage`.

---

## Current `live.md` structure

```
---
date: YYYY-MM-DD
employer: $EMPLOYER
generated_with: wk-sitrep:start
generated_at: ISO_8601_UTC
---

# Live — YYYY-MM-DD

<div class="sitrep-row">
<div class="sitrep-col">
**🗓 Section Header**
plain text meeting line · [link](url)
<span class="st-item"><span class="st-cb" data-t="tN" data-done="false" onclick="HANDLER"></span> Item text [link](url)</span>
<span class="st-item st-nested"><span class="st-cb" data-t="tN" data-done="false" onclick="HANDLER"></span> Sub-item text</span>
</div>
<div class="sitrep-col">
**🔴 Section Header**
<span class="st-item">...</span>
</div>
<div class="sitrep-col">
<div class="st-meta">📅 DATE · $EMPLOYER · wk-sitrep:start · HH:MM UTC</div>
**📣 Standup Snippet**
<div class="st-copy-block"><button class="st-copy-btn" onclick="COPY_HANDLER">Copy</button><pre class="st-standup">standup text here</pre></div>
</div>
</div>
```

**HARD RULE — no blank lines inside `<div>` blocks.** CommonMark ends HTML blocks at blank lines, breaking the column structure. Every line inside a column div must be contiguous (no blank lines between items).

## Checkbox span format

Each actionable item is wrapped in `<span class="st-item">` with a nested `<span class="st-cb">`:

```html
<span class="st-item"><span class="st-cb" data-t="tN" data-done="false" onclick="var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('$EMPLOYER/live').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('$EMPLOYER/live',c.replace(s,n))})"></span> Item text [link](url)</span>
```

- `data-t` is a sequential ID (t1, t2, … tN) — unique per item, per page.
- `data-done="false"` for pending items; `data-done="true"` for completed items.
- Nested sub-items use `class="st-item st-nested"`.
- Auto-action items (already done at generation time) start with `data-done="true"`.

## Graduating to snapshot (`wk-sitrep end`)

The `end` sub-command must detect done vs pending using `data-done` attributes, NOT `✅`/`⬜` glyphs or `[x]`/`[ ]` syntax (those no longer exist in this format).

**Done items** (→ snapshot achievements): `data-done="true"` spans.
**Pending items** (→ carry-forward in new live.md): `data-done="false"` spans.

Extract done items by parsing `data-t` + surrounding display text from `data-done="true"` spans. Extract pending items from `data-done="false"` spans. Non-checkbox content (meeting lines, section headers, standup block) is date-specific — drop it from carry-forward.

## space-style page

All CSS lives in `$EMPLOYER/sitrep-style.md` (a `#meta` page with a `space-style` block). Never regenerate it daily — only update `live.md`. After editing `sitrep-style.md`, force re-application via:
```javascript
const pg = await window.client.space.readPage('$EMPLOYER/sitrep-style');
await window.client.space.writePage('$EMPLOYER/sitrep-style', pg.text);
location.reload(true);
```
