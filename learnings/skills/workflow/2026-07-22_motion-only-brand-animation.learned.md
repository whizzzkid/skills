---
skill: wk-workflow
date: 2026-07-22
type: correction
severity: medium
---

For decorative/brand UI animation, default to motion-only (opacity, transform, position) and never animate hue/color-flow unless asked.

**What happened:** Built an animated ASCII brand wordmark with a color-gradient shimmer sweeping through the glyphs. The user rejected it as "jarring with the colors flowing through" and asked to keep the animation limited to the glyphs — change them one character at a time to show interactivity, but not change colors. Reworked into a monochrome per-character opacity ripple (color constant, motion staggered by column index).

**Root cause:** Color-cycling animation reads as noisy/distracting on a brand mark and fights the design token palette; the agent reached for a flashy color effect where a restrained motion cue was wanted. The instruction to "add animation" was taken as license to animate color too.

**Suggested fix:** When adding animation to a brand/decorative element, prefer motion-only channels (opacity, transform, position) and hold color constant unless the user explicitly asks for a color effect. Also: validate any theme-aware UI in BOTH light and dark mode before declaring done, and always route color/spacing through existing design tokens rather than introducing new values. When unsure about a visual-design choice, consult a design reference/skill rather than guessing.
