---
class: principle
skill: wk-find-cli
date: 2026-11-20
---

# Resolve a package's install dir before searching for its assets

- **Rule:** When the target lives outside `$PWD` (an installed package or gem asset), resolve its install dir in one
  call first (`bundle show <gem>`, `gem contents <gem>`, `npm root`, `pip show -f <pkg>`), then search only inside
  that dir. Never search from the filesystem root.
- **Why:** To check a claim about a vendored asset, the agent ran a root-level `find`, which broke the PWD rule and
  stalled until the call timed out. The package manager already knew the location.
- **Where:** `SKILL.md` → Step 1. The escape-`$PWD` bullet was escalated one rung (`**Important:**`) as a re-violation
  of the HARD RULE installed before the report.
