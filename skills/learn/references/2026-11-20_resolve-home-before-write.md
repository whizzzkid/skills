---
class: principle
source: learnings/skills/learn/2026-11-20_resolve-home-before-write.learned.md
date: 2026-11-20
skill: wk-learn
---

**Rule** — Build every Write path from the skills-home value Step 1 prints; never hand-type it.

**Why** — The Write tool needs an absolute path and expands no shell variables. An agent typed the path from memory,
created stray directories outside the skills home, and had to move the file after echoing the variable.

**Classification** — `principle`, new Step 1 bullet. The report's root cause ("Step 1 never prints the value") was
checked against source and is wrong: Step 1 already prints `OK: <value>`; the gap was that nothing tied Write paths to
that output.

**Where** — `SKILL.md` → Step 1 (Check environment).
