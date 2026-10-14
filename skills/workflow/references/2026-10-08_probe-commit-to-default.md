---
class: principle
---

# Probe repo convention before the first branch, not at PR time

**Rule**

- Before creating any branch while on the default branch, gather PR-gated evidence: branch protection, `CODEOWNERS`,
  feature-branch merges in `git log --first-parent -10 origin/<default>`.
- Direct non-merge commits by the user and no protection → commit to default, no branch.
- The PR phase consumes that decision; it never re-decides it.

**Why**

- The convention probe lived in the PR phase, but the branch reflex fires at commit time — before that phase is
  reached — so the agent branched in a direct-to-default repo and the user asked why. (Root cause inferred from
  symptom; the placement mismatch is verified in the skill text.)
- The rule had existed since an earlier learning; a later compression also dropped its evidence list. Relocation is
  the load-bearing fix; the label records the re-violation.

**Escalation**

- Baseline → `**Important:**`, relocated to the Phase 2 branch pre-flight with the evidence list restored.

**Audit cleanup**

- The Phase 5 "push succeeded is not work complete" HARD RULE sent every PR-less push to `wk-pr`, contradicting
  commit-to-default; scoped to feature branches.

**Where**

`skills/workflow/SKILL.md` → Phase 2 branch pre-flight; Phase 5 pointer.
