---
class: principle
---

# Hook passes require proven staged input

**Rule** — Abort hook verification on staging failure and require the non-empty
staged path set to exactly match the intended fold before running hooks.

**Why** — Hook scripts commonly pass against an empty index. If staging fails
but the harness continues, a complete row of green hook statuses validates no
content.

**Where** — `SKILL.md` Step 5, `references/staged-path-scan.md`, and
`references/byte-budget.md`.
