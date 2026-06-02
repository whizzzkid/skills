---
class: principle
skill: wk-arch-review
date: 2026-06-02
severity: high
---

# RFC/spec document-quality gate

- **Rule:** Every doc this skill writes or edits must pass six checks before it
  is written — (1) machine-readable frontmatter (`title`, `type`, `status`,
  `author`, `created`, `last_updated`, `epic`, `reviewers`, `labels`, `related`
  as title + resolvable path/url); (2) Diátaxis separation of explanation /
  reference / how-to with a "How to read this" note up top; (3) one high-level
  block diagram plus one detail diagram per major block, each labeled to its
  section — never a single giant diagram; (4) every internal link resolves on
  disk and every ticket reference exists, with not-yet-created artifacts marked
  `TBD`; (5) no effort sizing unless the user supplied it, else `TBD` or omit;
  (6) findings are folded into the target doc without asking, then committed.
- **Why:** A run produced architecturally valid findings but an unusable spec —
  no frontmatter, one monolithic diagram, dangling links to artifacts that did
  not exist, and fabricated effort numbers. Architectural correctness is
  necessary but not sufficient; the document must be navigable, verifiable, and
  honest about what is unknown, or downstream readers cannot trust or act on it.
- **Where:** Step 4 — Document-quality gate (runs before both REVIEW findings
  reports and WRITE-mode specs); the Effort field in the Critical Findings block.
