---
skill: wk-self-review
date: 2026-04-27
type: gap
severity: medium
---

Self-review skill should reconcile new comments against already-submitted/pending self-review threads before posting.

**What happened:** On PR #NNN I posted a 5-comment pending self-review covering design decisions made in later commits. One of those comments (`publish.sh:180` — filter difference rationale, `--filter=blob:none` vs sandbox `--filter=tree:0`) duplicated content from an earlier self-review thread already submitted on `docs/specs/...:135` of the same PR. The user had to ask for reconciliation; I removed the duplicate after the fact.

**Root cause:** The skill's "Updating an Existing Self-Review" section instructs me to resolve stale comments and add new ones, but it does NOT prescribe a reconciliation step that lists existing self-review threads (resolved + unresolved + already-submitted) and checks each proposed new comment against them for topical overlap. On a long-running PR where self-review has been done in multiple rounds, the natural "what's new since last time" framing leads me to focus on recent changes without re-reading prior self-review notes — so I duplicate rationale that's already in the PR.

**Suggested fix:** Add a step between "Identify Comment-Worthy Changes" and "Present Comments for Approval":

```
## Step 2.5: Reconcile against existing self-review

Before presenting proposed comments, fetch all existing review threads
authored by the PR author (self-review):

  gh api graphql -f query='query { repository(...) { pullRequest(...) {
    author { login }
    reviewThreads(first: 100) { nodes { isResolved comments(first:100) {
      nodes { path line body author { login } } } } } } } }' \
    --jq '.data.repository.pullRequest | .author.login as $a |
          .reviewThreads.nodes[] |
          select(.comments.nodes[0].author.login == $a) |
          .comments.nodes[0] | {path, line, body}'

For each proposed new comment:
- If a previous self-review note covers the same rationale (even on a
  different file/line), DROP the new comment OR rewrite it as a
  cross-reference: "See related design note on `docs/specs/...:135`."
- Resolve the prior thread only if the rationale is now stale, not
  merely because the new comment restates it.

The goal: each design rationale appears exactly once on the PR. Spec
files are usually the right home; implementation-file notes should
either add NEW context or point at the spec.
```

Slug: `reconcile-with-existing-self-review`
