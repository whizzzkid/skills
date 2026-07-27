---
class: principle
skill: wk-gh
date: 2026-07-27
severity: high
---

**Rule** — Effective merge methods come from repository *rulesets*. Read
`repos/{owner}/{repo}/rulesets` and the `pull_request` rule's
`parameters.allowed_merge_methods` before any merge. Neither `gh repo view`'s
`squashMergeAllowed` / `mergeCommitAllowed` / `rebaseMergeAllowed` nor
`branches/{branch}/protection` reports a ruleset, so "all three allowed" from
either is not evidence a method will be accepted.

**Why** — `gh pr merge --merge` failed with "Merge commits not allowed on
repository" while `gh repo view` reported all three methods `true`. Rulesets are a
separate API surface from classic branch protection, and the repo-level
`*MergeAllowed` fields describe repo *settings*, not effective policy after
rulesets apply. Reading the ruleset returned `["squash"]`.

Surfacing the restriction only when the merge is refused is what makes this high
severity: the squash-only outcome collapsed the branch into one new commit, making
every per-item SHA recorded in a plan doc and a tracking issue unreachable from the
base. That was caught only because the merge was refused first — a pre-flight read
turns it into a decision the user makes before anything is destroyed.

**Verified against source** — on a live repo: `repos/{o}/{r}/rulesets` returns rc 0
with `[]` when no ruleset exists; `branches/{b}/protection` returns 404 `Branch not
protected` on that same repo; `gh repo view` reports all three methods `true`. The
three surfaces are confirmed disjoint. **Scope limit:** the empty-ruleset path was
exercised directly; the populated `allowed_merge_methods` shape comes from the
incident report's own verified reading, not from a repo re-driven here. The rule is
written so the empty case (`[]` → repo-level fields govern) is explicit rather than
inferred.

**Where** — `wk-gh` Step 3 (GitHub API mechanics) carries the pre-flight and the
disjoint-surfaces rule. `wk-pr-merge`'s squash-fallback step had an over-general
detection command reading `repos/{owner}/{repo}`'s `allow_*_merge` fields; it was
corrected to read the ruleset in the same pass, and gained the
squash-breaks-recorded-SHAs constraint.
