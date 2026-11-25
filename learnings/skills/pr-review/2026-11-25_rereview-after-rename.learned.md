---
skill: wk-pr-review
date: 2026-11-25
type: pattern
severity: medium
verified-against-source: n/a
---

Re-review after a rename: verify each thread by content at the new path, and check re-rulings across the whole library.

**What happened:** The fix commits renamed the check, its reference folder and its corpus folder. Every old thread's path and line went stale. Verifier agents had to be told the rename map and to search by content. Many "fixed" claims held for the items a thread named. But the same commits re-ruled cards and added check sentences that contradicted other cards and other lines of the check: an exception list missing a data class, a new out-of-scope sentence next to a clause it negates, and a card whose level and reasoning disagreed. The corpus README counts also went stale.

**Root cause:** The re-review steps check whether a named item was fixed. They don't check whether the fix created a new contradiction with sibling files that follow the same rule.

**Suggested fix:** In Phase 2 re-review: (1) when the delta renames paths, build an old-to-new path map, pass it to verifiers, and match threads by content, not line; (2) for every re-ruled or edited rule, grep the whole library for the same pattern and check that dependents (docs, counts, READMEs, sibling cards) still agree. Also: when the user asks for a shareable root message, write it as a separate markdown file, and keep the pending-review body to the verdict and the footer.
