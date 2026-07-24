---
class: principle
---

**Rule** — Enumerated tests for the Step 3 `principle` vs `one-off` classification gate. Any single
matching test decides the class; when tests from both lists match, ask once.

Classify as `principle` when any of these are true:

- The pattern appears in ≥ 2 prior learnings, memories, or `.learned.md` archives.
- The failure mode would surface on every invocation that touches the affected step.
- The fix is expressible in one bullet without naming specific tools, versions, or repos.

Classify as `one-off` when any of these are true:

- The fix requires a verbatim recipe that only works for one tool version or repo layout.
- The failure mode only fires under a rare configuration.
- The user described it as a corner case or one-time workaround.
- Distilling the principle leaves nothing actionable that is not already covered.

**Why** — The two class definitions and their routing are needed on every run and stay inline; the
eight tests are a lookup catalog consulted only when the class is not obvious, so they belong in an
extended file rather than in the always-loaded body.

**Where** — Step 3 → Classify: principle vs one-off.
