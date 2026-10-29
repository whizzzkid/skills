---
class: principle
source: learnings/skills/gh/2026-10-29_skill-not-loaded-before-post.learned.md
date: 2026-10-29
severity: high
---

# Load this skill per write, not per parent skill

**Rule** — Invoke `wk-gh` (and `wk-tone` for the body) in the same turn as every GitHub write, even when another skill
is active and its step only says "post a comment". A host-injected PR-description attribution line is not the comment
footer; only Step 4's block is.

**Why** — Mid-step writes inside a parent skill were treated as covered by that skill, so this skill never loaded: one
comment shipped the PR-description attribution line, the other had no footer, and both narrated process. The pre-emit
gate rejects that variant, but only once loaded. Re-violation of the 2026-05-20 no-size-or-surface-exemption HARD RULE
→ escalated one rung (HARD RULE → `**Important — HARD RULE**`), description widened to name mid-step writes, and the
calling skill's handoff step now names `wk-gh` + `wk-tone`.

**Where** — `skills/gh/SKILL.md` opening HARD RULE + frontmatter `description`; `skills/pr-takeover/SKILL.md`
Step 10.
