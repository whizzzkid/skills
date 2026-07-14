---
class: one-off
skill: wk-sitrep
---

# Checkbox-span toggle handler (canonical)

**Scenario:** Every actionable `live.md` item is a `<span class="st-item">` wrapping
a `<span class="st-cb">` whose `onclick` persists the `data-done` flip back to the
page. wk-silverbullet owns the span pattern but only with an `onclick="HANDLER"`
placeholder; this is the concrete handler.

**Recipe:**

```html
<span class="st-item"><span class="st-cb" data-t="tN" data-done="false" onclick="var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('$EMPLOYER/live').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('$EMPLOYER/live',c.replace(s,n))})"></span> Item text [link](url)</span>
```

**Why not promoted:** verbatim mechanical recipe, not a generalizable principle;
kept inline-pointer-only to hold `SKILL.md` under the size ceiling.
