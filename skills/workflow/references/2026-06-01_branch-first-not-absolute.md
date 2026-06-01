---
skill: wk-workflow
date: 2026-06-01
class: principle
type: correction
severity: medium
---

# "Branch first on the default branch" is a default, not an absolute

- **Rule:** Detect repo convention before auto-creating a feature branch.
  Branch only when evidence points to a PR-gated workflow (branch
  protection, CODEOWNERS, or merge history from feature branches);
  otherwise commit straight to the dynamically-resolved default branch.
  Resolve the default branch via
  `git symbolic-ref refs/remotes/origin/HEAD` — never assume a literal name.
- **Why:** An agent auto-branched on a solo-maintained repo that commits
  directly to its default branch; the branch caused friction and the user
  asked why it existed. Signals of a direct-to-default repo: near-empty
  `git log --oneline --merges -20`, no branch protection
  (`gh api repos/{owner}/{repo}/branches/{branch}/protection` 404s), no
  CODEOWNERS, solo maintainer.
- **Where:** `Phase 5: PR → Detect repo convention before branching`
  (after the opening HARD RULE, before "After code review passes, invoke
  `wk-pr`").
