---
class: principle
---

# Decorative animation defaults to motion-only; validate both themes

**Rule**

- When animating a brand or decorative element, animate motion channels only
  (opacity, transform, position) and hold color constant. Introduce a
  color/hue-cycling effect only when the user explicitly asks for one.
- A theme-aware surface must be validated in BOTH light and dark mode before
  sign-off, not just the theme it was authored in.

**Why**

- Color-cycling on a brand mark reads noisy and fights the design-token palette;
  "add animation" is a motion cue, not license to animate hue. A restrained
  per-element motion effect conveys interactivity without the distraction.
- A token that passes contrast on one background can fail on the other, so a
  single-theme review ships a broken surface.

**Where**

- `design-review` Step 3 anti-patterns (color-cycling flag) and Common Mistakes
  (single-theme sign-off).
