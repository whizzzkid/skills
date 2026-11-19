---
class: principle
source: learnings/skills/skill/2026-11-19_overlap-before-scaffold.learned.md
date: 2026-11-19
skill: wk-skill
---

**Rule** — After the name-collision check clears, grep every skill's `description:` for the request's key nouns and
verbs and read each hit. On a substantial overlap, ask whether to extend that skill via `wk-sharpen` or create a new
one before scaffolding. Write example PR/issue numbers as `#NNN` placeholders in markdown.

**Why** — The collision guard was `test -d skills/<name>`: a name match, not a capability match. A request for a new
skill reported `CLEAR` while an existing skill already covered most of the behavior; only a manual listing surfaced
it, and the user chose to extend the existing skill. Separately, the PR-number pre-commit hook rejects literal
numbers in markdown, so drafting them forces a rewrite.

**Where** — `SKILL.md` → Steps 1–2 (item 4, capability check) and Step 6 (README placeholder note); README flow and
Noteworthy.
