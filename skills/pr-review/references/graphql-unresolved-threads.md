# GraphQL: Unresolved Review Threads

Shared query used by `wk-pr-review` (Phase 2/4), `wk-pr-merge` (Step 4), and
`wk-pr-resolve`.

```bash
gh api graphql -f query='
  query($owner:String!, $repo:String!, $number:Int!) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$number) {
        reviewThreads(first:100) {
          nodes { id isResolved isOutdated path line
            comments(first:1) { nodes { author { login } body } }
          }
        }
      }
    }
  }' -F owner="{owner}" -F repo="{repo}" -F number={number} \
  --jq '.data.repository.pullRequest.reviewThreads.nodes
        | map(select(.isResolved == false and .isOutdated == false))'
```

## REST comments endpoint (no resolution state)

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, updated_at, in_reply_to_id}'
```

Filter root inline comments only — skip entries with `in_reply_to_id` (replies,
not thread anchors). REST carries no `isResolved` / `isOutdated`; use the
GraphQL query above for resolution state.

## Thread resolution mutation

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) { thread { isResolved } }
  }
' -f threadId="THREAD_NODE_ID"
```
