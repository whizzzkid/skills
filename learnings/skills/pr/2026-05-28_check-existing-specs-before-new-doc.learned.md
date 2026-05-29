---
skill: wk-pr
date: 2026-05-28
type: gap
severity: medium
---

Creating a standalone spec doc when a related spec already exists in an open PR causes a merge/consolidation request.

**What happened:** A new spec was created for a feature. A related open PR contained a base spec for the same domain. The user redirected: "can we merge the spec we just added to this PR with the spec being introduced here [link]?" requiring a doc merge + rebase.

**Root cause:** The agent checked the current branch's docs but not open PRs' diffs for existing specs in the same domain. A spec for "per-repo auto-approve config" was created alongside (not merged into) a base spec for "auto-approver design" that was in flight in another PR.

**Suggested fix:** Before creating a new spec file, search open PRs for docs touching the same domain: `gh pr list --state open --json number,files --jq '.[] | .files[].path' | grep 'docs/specs'`. If a related spec exists in an open PR, prefer extending it via stacking rather than adding a parallel doc.
