---
skill: wk-pr
date: 2026-07-22
type: gap
severity: high
---

A PR stack sliced with an enforcement/gate PR upstream of the PR that supplies the data the gate requires is CI-red in isolation.

**What happened:** A 6-PR stack put an enforcement PR (validate requires `version:` frontmatter on every check) as the parent of the backfill PR that adds that frontmatter. The enforcement PR failed CI in isolation because the required data did not yet exist on its base. Fixing it needed `git rebase --onto` surgery to invert the parent/child relationship after both PRs were already created.

**Root cause:** Stack slicing ordered PRs by conceptual layering (schema → enforcement → data) rather than by data-dependency. A gate consumer must be downstream of its data provider so each PR is independently green.

**Suggested fix:** When slicing a stack, add a pre-creation check: for any PR that adds a gate/validation/enforcement that fails on missing data, verify the PR providing that data is an ancestor in the stack. Order by data-dependency, not conceptual layer. Each PR must pass CI on its own base.
