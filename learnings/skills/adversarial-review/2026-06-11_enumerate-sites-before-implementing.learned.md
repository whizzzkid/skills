---
skill: wk-adversarial-review
date: 2026-06-11
type: gap
severity: high
---

For cross-cutting changes, enumerate ALL affected call sites before writing any code — then implement all in one pass and run adversarial review exactly once.

**What happened:** A normalization change (case-insensitive codebase matching) was implemented site by site — core resolution first, then tests, then upsert, then validators, then ordering/contiguity — with an adversarial review after each group. Each review found the next layer. Five commits and three review rounds instead of one implementation commit and one clear review.

**Root cause:** The agent didn't grep for all sites where the affected pattern appeared before writing the first line of code. Without a complete site map, each review round reveals the next missed site.

**Suggested fix:** Before any cross-cutting change (normalization, renaming, adding a required field, changing a schema), run: `grep -rn '<pattern>' scripts/` and enumerate every affected site. Write all fixes in one pass, run adversarial review once, fix residuals in one follow-up commit at most. Never commit a partial fix and expect review to fill the gaps.
