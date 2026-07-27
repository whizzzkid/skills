---
skill: wk-gh
date: 2026-07-27
type: surprise
severity: high
verified-against-source: yes
---

Allowed merge methods can be restricted by a repository **ruleset**, which neither the classic branch-protection endpoint nor `gh repo view` reports.

**What happened:** `gh pr merge --merge` failed with "Merge commits are not allowed on this
repository." `gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed`
returned `true` for all three, and `gh api repos/{o}/{r}/branches/{branch}/protection` showed
nothing about merge methods. The real restriction lived in a ruleset's `pull_request` rule:

```bash
gh api repos/{o}/{r}/rulesets --jq '.[] | {id, name, target}'
gh api repos/{o}/{r}/rulesets/{id} \
  --jq '.rules[] | select(.type=="pull_request").parameters.allowed_merge_methods'
```

which returned `["squash"]`. Squash would have collapsed the branch into one new commit and made
every per-item SHA recorded in the plan doc and tracking issue unreachable from the default
branch — caught only because the merge was refused.

**Root cause:** Rulesets are a separate API surface from classic branch protection, and the
repo-level `*MergeAllowed` fields describe repo settings, not the effective policy after rulesets
apply. Verified by reading the ruleset object and by the merge succeeding once `merge` was added
to `allowed_merge_methods`.

**Suggested fix:** Add a merge-method pre-flight that reads `rulesets` (not just
`branches/{b}/protection` or `gh repo view`) and treats `allowed_merge_methods` as authoritative.
Note that "all three methods allowed" from `gh repo view` is not evidence, and that a
squash/rebase-only repo is a hard stop for any branch whose commits are referenced by SHA
elsewhere — surface it to the user before merging rather than discovering it at merge time.
