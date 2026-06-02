---
skill: wk-arch-review
date: 2026-06-02
type: gap
severity: high
---

RFC/spec reviews must enforce document quality, not just architectural correctness.

**What happened:** wk-arch-review produced valid architectural findings but the output
spec lacked structured frontmatter, used a single monolithic diagram instead of layered
ones, contained links to not-yet-created artifacts without TBD markers, and included
fabricated effort sizing. The user had to enumerate all of these as post-review feedback.

**Root cause:** The skill focuses on architectural lenses (SPOFs, unhappy paths, etc.)
but has no document-quality gate. These are separate concerns — a doc can be
architecturally sound and structurally unusable for an RFC audience.

**Suggested fix:** Add a mandatory document-quality pass to Step 4 (before writing the
findings report) that enforces:
1. Structured machine-readable frontmatter: title, type, status, author, created,
   last_updated, epic, reviewers, labels, related (with title + path/url).
2. RFC best-practice structure + Diátaxis separation: explanation (why/motivation)
   separate from reference (what/interfaces) separate from how-to (guide/tutorial).
   Add a "How to read this RFC" note at the top.
3. Diagram discipline: one high-level block/interaction diagram showing all parts and
   contracts between them, then one detail diagram per major block/component. Never a
   single giant diagram. Label which detail diagram belongs to which spec section.
4. Link validation: every internal doc link must resolve on disk (Read or Glob check);
   every Jira/ticket reference must exist; any reference to not-yet-created artifacts
   (stories, future tickets, unwritten docs) must be marked TBD explicitly.
5. Sizing discipline: never include effort estimates unless the user supplied them.
   Mark sizing as TBD or omit entirely.
Also: all wk-arch-review findings are mandatory to incorporate into the target doc —
never ask the user whether to fold them in. Do it, then commit.
