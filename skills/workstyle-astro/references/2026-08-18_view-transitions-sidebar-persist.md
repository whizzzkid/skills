---
class: principle
---

**Rule** — The complete view-transitions-for-docs-sites pattern (ClientRouter +
transition:persist + astro:after-swap sync + scroll-preserving CSS +
is:inline head scripts + testMarker verification) is already covered by the
View Transitions, Head Scripts, Layout and Components, and Accessibility
sections of SKILL.md.

**Why** — Classified `already-covered` with positive-steering evidence: the
session retro's "What worked" confirms the pattern was correctly identified and
verified live via Playwright before committing. No escalation.

**Where** — No SKILL.md edit. Coverage proven by:
- View Transitions § bullet 1 (ClientRouter)
- View Transitions § bullet 2 (transition:persist on sidebars)
- View Transitions § bullet 3 (astro:after-swap aria-current sync)
- View Transitions § bullet 4 (window.__testMarker verification)
- Head Scripts § bullet 1 (is:inline re-runs on navigation)
- Layout and Components § bullet 2 (sticky + overflow-y + max-height)
