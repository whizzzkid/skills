---
class: principle
---

**Rule** — A learning's `skill:` frontmatter field names the reporter's *suspected* owner,
not a resolved target. When the dir listing comes back empty, do not retry the path and do
not file it as a gap — fall through to the subject grep and route the lesson to the skill
whose body owns the mechanics.

**Why** — Step 2 previously conflated two distinct failures: "the dir name is not a
mechanical transform of `name:`" (handled) and "no dir corresponds to this name at all"
(unhandled). The second is normal input, not malformed input: learnings dirs are created on
demand and never prefixed, so an item can be filed against a tool, language, or interpreter
that owns no skill dir. The empty glob then reads like the mis-resolution the adjacent rule
warns about, and the neighbouring "unverified until the path is confirmed to exist" rule
pushes toward re-checking the path rather than abandoning it.

**Boundary** — The zero-match rule governs a *content grep at a resolved dir*; this rule
governs an *empty dir listing*. They are not in tension, and the fold states the boundary
explicitly so the next reader does not resolve it the wrong way.

**Where** — wk-sharpen Step 2, as a sub-bullet of the dir-resolution rule. The same step's
cross-skill grep clause already covers correcting the consuming instance once the real owner
is identified.
