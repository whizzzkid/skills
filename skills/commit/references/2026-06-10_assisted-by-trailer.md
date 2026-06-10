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
