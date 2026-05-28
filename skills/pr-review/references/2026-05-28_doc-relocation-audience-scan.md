---
class: principle
date: 2026-05-28
source:
  - learnings/skills/pr-review/2026-05-28_doc-only-vocabulary-portability.md
severity: low
---

- **Rule** — when a PR is a doc relocation (file imported from another repo or org, no code changed), Phase 3 runs an audience-portability scan in addition to surface checks.
- **Why** — surface audits (hard-coded paths, broken anchors) catch shape but miss vocabulary portability: org-specific tooling names, internal short-links, task-tracker IDs, and back-references to files that exist only in the source environment lose meaning after relocation. Surface-pattern bots routinely miss this class.
- **Where** — new "Doc-relocation audience scan" paragraph in `wk-pr-review` Phase 3 (Investigation), before the existing "Be adversarial" block. Findings posted as `suggestion`-severity inline comments so authors can rewrite, gloss, or knowingly preserve.
