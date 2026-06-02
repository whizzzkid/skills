---
skill: wk-brainstorming
date: 2026-06-02
type: gap
severity: medium
---

Enforce RFC/spec structural conventions at write-time, not through user review.

**What happened:** A spec was written from brainstorming output but lacked structured
frontmatter, used a single monolithic diagram, had unresolved placeholder links, and
included fabricated sizing estimates. The user had to enumerate all of these as feedback
after reading the draft, requiring multiple revision cycles before the doc was RFC-ready.

**Root cause:** The brainstorming skill produces good content but has no structural
write-time gate for specs/RFCs. Structural conventions (frontmatter, diagram discipline,
link validation, sizing policy) were treated as post-write reviewer concerns instead of
authoring constraints.

**Suggested fix:** Before writing any spec/RFC from the design doc step, apply a
structural checklist:
1. YAML frontmatter: title, type, status, author, created, last_updated, epic,
   reviewers, labels, related.
2. One high-level block/interaction diagram + one detail diagram per major component;
   never a single giant diagram.
3. Validate every doc path and ticket link before writing (Read/Glob to confirm paths,
   Jira MCP to confirm tickets exist); mark not-yet-created artifacts TBD.
4. No effort sizing unless the user supplied estimates; mark TBD or omit.
5. "How to read" navigation note at the top (short — no framework branding).
This checklist runs before committing any spec file, not after the user reads a draft.
