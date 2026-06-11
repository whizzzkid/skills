---
class: principle
---

- **Rule** — When a sharpen edit changes a skill's described behavior, sync
  the downstream doc surfaces in the same pass: the skill's `README.md` and
  its Mermaid diagram, both repo index tables (root `README.md` +
  `skills/README.md`) when the one-line description changed, and `docs/` via
  `wk-docs` when cross-skill behavior changed.
- **Why** — A SKILL.md change leaves every doc that describes the skill stale —
  the exact drift the skill warns reviewers about; readers trust the README and
  index over the SKILL.md.
- **Where** — Step 7, new sub-section "Sync skill README, diagrams, and
  repo-level docs"; commit-group bullet in Step 8 extended to include them.
