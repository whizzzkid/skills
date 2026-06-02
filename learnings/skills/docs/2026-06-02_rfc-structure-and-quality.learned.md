---
skill: wk-docs
date: 2026-06-02
type: gap
severity: high
---

All specs, RFCs, and design docs must follow a quality checklist before delivery.

**What happened:** A spec/RFC was written without structured frontmatter, used a single
monolithic architecture diagram, had unresolved links to not-yet-created artifacts (no
TBD markers), and contained effort estimates that were not user-supplied. Multiple rounds
of revision were needed to bring the doc to RFC-ready standard.

**Root cause:** wk-docs has no mandatory pre-delivery checklist for specs/RFCs. The skill
writes correct content but does not enforce the structural and navigational conventions
that make a doc reviewable by an RFC audience.

**Suggested fix:** Before writing or finalizing any spec/RFC/design doc, enforce:
1. Frontmatter block (YAML): title, type (RFC | spec | ADR | plan), status, author,
   created, last_updated, epic (ticket URL), reviewers (list), labels, related (list of
   {title, path/url}). Machine-readable so tooling can index it.
2. Diátaxis structure: separate explanation (why — motivation, context, goals) from
   reference (what — interfaces, schemas, precise specs) from guide/tutorial (how —
   worked examples, walkthroughs). Add a "How to read this doc" note at the top naming
   the sections and what each reader type should focus on.
3. Diagram discipline: one block/interaction diagram at the top of the guide section
   showing all major components and their contracts; then one focused detail diagram per
   major component (in that component's own section). Never one giant diagram.
4. Link hygiene: resolve every doc path on disk before writing; check every ticket/URL;
   mark references to not-yet-created artifacts as TBD explicitly with a note.
5. No fabricated sizing: omit effort estimates or mark TBD unless the user provided them.
