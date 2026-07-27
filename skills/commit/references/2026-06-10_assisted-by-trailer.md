---
class: principle
date: 2026-06-10
severity: medium
---

- **Rule:** Every agent-created commit carries an `Assisted-by: <Tool/Agent
  Name> <version>` footer trailer, alongside any `Co-Authored-By:` / `Generated
  with` lines.
- **Why:** Provenance — a commit produced by an agent should name the agent and
  version that authored it; wk-commit is model-invocable, so its commits are
  agent-created by definition.
- **Where:** Commit Message Format → "Mandatory footer trailer — Assisted-by".
- **Superseded in part (2026-07-27):** "alongside any `Co-Authored-By:` /
  `Generated with` lines" read as an expectation that those trailers accompany
  `Assisted-by:`, and contributed to trailers being copied from sibling commits.
  The trailer set is now closed — see
  [`2026-07-27_closed-trailer-set.md`](2026-07-27_closed-trailer-set.md).
