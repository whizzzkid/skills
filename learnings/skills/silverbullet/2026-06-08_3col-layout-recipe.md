---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: high
---

Complete recipe for a working 3-column interactive dashboard in SilverBullet 2.x.

**What happened:** Multiple approaches were tried before finding the working combination. The final solution required: no-blank-line HTML blocks + span checkboxes + window.client API + CSS space-style.

**Working recipe:**

**1. space-style block (in `#meta` page):**
```css
.sitrep-row { display: flex; flex-direction: row; gap: 0.8rem; width: 100%; align-items: flex-start; }
.sitrep-col { flex: 1; min-width: 0; padding: 0.7rem 0.9rem; border-radius: 8px; }
.st-cb { cursor: pointer; user-select: none; display: inline; }
.st-cb[data-done="false"]:before { content: '☐'; font-size: 1.25em; margin-right: 4px; }
.st-cb[data-done="true"]:before { content: '☑'; font-size: 1.25em; margin-right: 4px; color: #39ff14; }
.st-item { display: block; padding-left: 1.1em; line-height: 1.75; }
.st-item:has(.st-cb[data-done="true"]) { text-decoration: line-through; opacity: 0.55; }
.sb-frontmatter { display: none !important; }
```

**2. Page structure (NO blank lines inside divs):**
```
<div class="sitrep-row">
<div class="sitrep-col">
**Section Header**
<span class="st-item"><span class="st-cb" data-t="t1" data-done="false" onclick="HANDLER"></span> Item text [link](url)</span>
</div>
<div class="sitrep-col">...</div>
<div class="sitrep-col">...</div>
</div>
```

**3. onclick handler (no `>` or `"` inside attribute value):**
```
var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('page-name').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('page-name',c.replace(s,n))})
```

**What does NOT work:** `<input type="checkbox">` (disabled by SilverBullet), `fetch()` for file I/O (service worker intercepts), `- [ ]` inside table cells (renders as text), blank lines inside div columns (breaks CommonMark HTML block).
