---
skill: wk-commit
date: 2026-04-27
type: gap
severity: medium
---

When a CI fix loop produces many small "try this" commits that are not independently meaningful, offer to squash before pushing the next round (or before the PR merges).

**What happened:** Across one PR I committed and pushed each individual CI fix attempt as its own commit: `add reshim`, `use mise exec`, `use lycheeverse/lychee-action`, `revert to mise-action`, `inline MISE_TASK_RUN_AUTO_INSTALL`, `use MISE_AUTO_INSTALL=false`, `pin lychee to 0.24.1`, `use ubi backend`, `use aqua backend`, `install lychee directly`, `find binary in tarball`, `update include_fragments to string`, `pin lychee to 0.23.0`, `revert include_fragments to bool`. The branch ended up with ~12 fix commits where the actual change was "pin lychee to 0.23.0 in mise.toml." Each commit individually passed `wk-commit`'s rules, but the resulting history is noise.

**Root cause:** `wk-commit` enforces atomicity per commit (one logical change, signed, conventional, push) but has no rule about *what shape the branch should be in by the time it merges*. The CI fix loop produces lots of micro-commits when each fix is its own theory; left as-is, they pollute `git log` and obscure the actual change for future readers.

**Suggested fix:** After the CI fix loop exits green, `wk-commit` (or `wk-pr` in Phase 5) should check whether the branch has a long tail of `fix(ci):` commits whose net diff is small (say, <50 lines across N>3 commits) and offer to squash them into a single commit before marking the PR ready. The offer is one-line ("Want me to squash the 12 CI fix commits into a single 'fix(ci): pin lychee 0.23.0 …' commit?") — destructive enough that the user should approve, but cheap enough to be worth offering. Don't auto-squash. Don't squash across user-authored commits.
