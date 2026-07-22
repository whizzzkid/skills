---
skill: wk-adversarial-review
date: 2026-07-22
type: gap
severity: medium
---

A merge that re-scopes CSS selectors to raise specificity can silently defeat a lower-specificity modifier encoding a design invariant, and no request spec catches it.

**What happened:** During a merge-conflict resolution, base was integrated by scoping a base rule under a parent (`.stat-strip .stat-tile`, specificity 0,2,0). That silently overrode a pre-existing `.stat-tile--pending` modifier (0,1,0) that set `border-style: dashed` — the design system's "pending placeholder tile" invariant. The dashed border reverted to solid with zero test failures. The adversarial gate also found orphaned dead CSS (an empty rule + an `:empty +` sibling selector) left behind after a layout change replaced the container those selectors targeted. Mechanical sweeps missed both; the fresh adversarial pass caught them.

**Root cause:** CSS specificity conflicts are invisible to request/DOM-presence specs — the element and class are still present, only the computed style is wrong. A merge that adds a parent scope to raise a base rule's specificity is exactly the change that can outrank a design-invariant modifier on the same element, and nothing in the diff of either side looks wrong in isolation.

**Suggested fix:** Add a sweep trigger: when a diff re-scopes a CSS selector (adds a parent/ancestor to raise specificity), re-audit every lower-specificity modifier targeting the same elements and confirm the intended cascade still wins. Treat design-token / invariant regressions (dashed pending tiles, contrast/WCAG) as first-class blockers even when tests are green, since specificity bugs never fail a spec. Also flag selectors whose target element no longer exists after a layout change as dead code.
