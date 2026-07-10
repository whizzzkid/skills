---
skill: wk-commit
date: 2026-07-10
type: correction
severity: low
---

Agent self-initiated `git commit --amend` on an unpushed commit to fold in a follow-up fix, contrary to the new-commits-only rule.

**What happened:** Mid-task, after strengthening a just-created (not-yet-pushed) commit, the agent amended it rather than creating a new commit — reasoning the change was low-risk since nothing had been pushed. This bypasses the standing "create NEW commits rather than amending unless the user explicitly requests an amend" hard rule, which is unconditional and not gated on whether the commit was pushed.

**Root cause:** The agent treated "not yet pushed" as an implicit exemption from the amend prohibition. The rule has no such carve-out; unpushed status changes the blast radius, not the rule's applicability.

**Suggested fix:** State explicitly that the amend prohibition holds regardless of push state — an unpushed commit is not a license to amend. When tempted to fold a follow-up into the prior commit, create a new commit and, if consolidation is wanted, surface an explicit amend/squash suggestion for the user to approve (mirrors the existing amend-discipline guidance).
