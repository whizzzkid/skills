---
class: principle
---

**Rule** — When an edit pushes a SKILL.md over a body-size ceiling, prefer structural moves over prose-mangling to reclaim bytes: (1) relocate narrow, language/tool-specific catalog rows to a `references/` extended file and update the inline pointer's ID list; (2) merge a new row into the existing row it conceptually overlaps. Reserve prose compression for the final small margin.

**Why** — Catalog rows are information-dense; compressing them line-by-line risks dropping a distinct check for little savings and is slow. Relocation and merge reclaim far more bytes per edit with zero coverage risk. An existing extended-references file is an underused relief valve.

**Where** — Step 7.5 size-ceiling rule. Proven by repeated use this session relocating sweep rows to the extended catalog.
