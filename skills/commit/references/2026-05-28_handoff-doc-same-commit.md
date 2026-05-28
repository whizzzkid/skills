---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_handoff_doc_cleanup.md
severity: low
---

- **Rule** — stage the deletion of an agent-written handoff doc (`NEXT_PHASE.md`, `HANDOFF.md`, planning markdown) in the same commit that applies the described work.
- **Why** — a separate cleanup commit produces a markdown-only diff that triggers full CI on no real change and can surface flaky failures unrelated to the work.
- **Where** — new "Stage handoff-doc removal with the work it describes" subsection in `wk-commit` SKILL.md, between Hook and verify rules and Post-Push: PR Sync.
