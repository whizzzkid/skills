---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: low
---

CSS `:has()` selector works in SilverBullet's HTML widgets — use it for parent-based state styling without JavaScript.

**What happened:** Used `.st-item:has(.st-cb[data-done="true"])` to apply strikethrough + opacity to a checkbox item's entire line when its child span was marked done. This worked correctly with no JavaScript needed for the visual effect.

**Root cause:** SilverBullet runs in a modern browser that fully supports CSS `:has()`. The `space-style` CSS rules apply to `.sb-html-widget` content just like any page CSS.

**Suggested fix:** Prefer `:has()` over JavaScript DOM manipulation for state-based styling. Pattern for done-state items:
```css
.item-container:has(.checkbox-span[data-done="true"]) {
  text-decoration: line-through;
  opacity: 0.55;
}
```
The `data-done` attribute is toggled by the onclick handler; CSS reacts automatically without any separate style-update code.
