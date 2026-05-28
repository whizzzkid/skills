---
skill: wk-pr-review
date: 2026-05-28
type: gap
severity: low
---

Doc-only PRs can carry org-specific jargon and tooling references that lose meaning after repo relocation.

**What happened:** Reviewed a doc-only plan import. Copilot bot caught the surface-level pattern (hard-coded absolute paths). The review surfaced a deeper class the bot missed: pickleton-org-specific vocabulary (`bean` for work items, `pt checkout` for worktree bootstrap, `agent-meta:park` for session handoffs, internal tracking IDs like `gt-690a`, and external memory file references like `feedback_*.md`) that became opaque once the doc moved to gdev-wish.

**Root cause:** Phase 3 investigation checklist doesn't include an "audience mismatch" scan for relocated docs — the skill focuses on code correctness, not project-vocabulary portability.

**Suggested fix:** When the diff is a doc relocation (file imported from another org or repo, no code changed), Phase 3 should include one additional adversarial question: "Does this doc contain org-specific tooling names, task-tracker IDs, or back-references to files/memory that don't exist in the destination repo?" Flag each as a `suggestion`-severity inline comment so the author can selectively address or knowingly preserve them.
