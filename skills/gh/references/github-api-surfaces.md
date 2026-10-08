# Canonical Surface for GitHub Writes

Every skill that creates or edits GitHub-visible content routes
through this skill's conventions. Read-only `gh` calls (view, diff,
search, api GET) do not require this routing — only writes.

Surfaces covered (non-exhaustive):

- PR title and body (`gh pr create`, `gh pr edit`)
- Review body and inline review comments (`gh api .../pulls/{n}/reviews`)
- Inline-comment replies (`gh api .../pulls/{n}/comments/{id}/replies`)
- Issue and PR conversation comments (`gh issue comment`, `gh pr comment`)
- Review-thread state changes (resolve/unresolve via GraphQL)

**Never POST to `/issues/comments/{id}` — GitHub routes it as update (same as
PATCH), silently overwriting the body (rc 200, existing id → `|| fallback` never
fires).** Conversation comments have no reply subresource; a new comment is always
`POST /issues/{n}/comments`. Before any write adjacent to another author's
comment, capture its body for recovery.
After any conversation write, re-list the surface → new comment ID must appear, prior comments body lengths unchanged.

**Inline-reply IDs are numeric REST IDs.** `in_reply_to` (and
`/pulls/{n}/comments/{id}/replies`) require the integer REST `id` from
`GET /pulls/{n}/comments` (or `databaseId` from a GraphQL reviewThreads query),
not a GraphQL node ID (`PRRC_…`) — passing the node ID returns 404.

**Retarget a PR base via REST, not `gh pr edit --base`.** `gh pr edit --base`
drives the change through the GraphQL `updatePullRequest` mutation, which
intermittently 500s (`GraphQL: Something went wrong while executing your query`)
for base changes — notably right after reopening a PR or recreating branches. Use
`gh api -X PATCH repos/{owner}/{repo}/pulls/{n} -f base=<branch>`; fall back to it
automatically after ONE GraphQL failure rather than retrying the mutation.

**Prefer the `/replies` subresource over `in_reply_to`.** `POST
/pulls/{n}/comments/{id}/replies --field body="…"` is simpler and sidesteps
`in_reply_to` formatting entirely. If using the base endpoint, pass the ID with
`--field in_reply_to=<int>`, never `-f` — `-f` sends a string and returns 422
("is not a number"). **The single-comment GET is asymmetric with the reply POST:**
`GET /pulls/comments/{id}` carries **no PR number**; the reply is `POST
/pulls/{n}/comments/{id}/replies`. `/pulls/{n}/comments/{id}` matches no route, so
it 404s even for a live comment. Tell them apart by the error body: generic
`documentation_url` (`docs.github.com/rest`) = no route matched;
operation-specific = route matched, resource gone. A `GET` 404 is never evidence
writes fail: a bot replacing its review 404s the stale `databaseId` while `POST
.../comments/{id}/replies` on it still returns 201 — try that POST before GraphQL.

**Build any non-trivial `gh api` POST/PATCH JSON body with `jq -n`, never a heredoc.**
Hand-escaping quotes/backticks in a heredoc-interpolated JSON literal corrupts the
structure on any special char in the content, and the server returns an opaque
`HTTP 400 "Problems parsing JSON"` — no local syntax error to catch it first. Let `jq`
own the escaping regardless of body content:

```bash
jq -n --arg body "$text" '{body: $body, event: "COMMENT"}' \
  | gh api repos/{owner}/{repo}/pulls/{n}/reviews --input -
```

**Build `gh pr edit --body`/`--body-file` from a heredoc or a written file — never
stream edits through `sed`/`awk`.** BSD `sed` `i`/`a`/`c` need a backslash-newline
continuation, not the GNU inline form; a parse failure emits nothing, so
`BODY=$(echo "$BODY" | sed …)` silently becomes an empty string and `gh pr edit`
overwrites the description with a blank body while reporting success. Always
re-fetch after any body edit — `gh pr view --json body --jq '.body | length'` — a
"Body updated" message is not proof the content survived.

**A pending review silently swallows a GraphQL reply.** When the acting user
already has a PENDING review on the PR, the `addPullRequestReviewComment`
mutation with `inReplyTo` set but `pullRequestReviewId` omitted attaches the
reply to that pending draft instead of publishing it — no error, the new comment
returns `state: "PENDING"`, and it stays invisible until the draft review is
later submitted. Guard every reply post:

- Query `pullRequest.reviews(states: PENDING)` for the acting user first. If a
  pending review exists, use the REST `/replies` endpoint (it fails loudly with
  422 `user_id can only have one pending review`) or surface the pending review
  and wait for the user to resolve it — do not post via GraphQL.
- Never treat a `state: "PENDING"` response from a reply mutation as success —
  read the returned `state` and treat any non-published state as a failure needing
  remediation.
- **Pending-review creation, parse failures, and REST block details:**
  [`pending-review-mechanics.md`](pending-review-mechanics.md).

**Effective merge methods come from repository *rulesets* — neither `gh repo view`
nor branch-protection reports them.** `gh repo view --json
squashMergeAllowed,...` returns repo *settings*; `branches/{branch}/protection`
404s without classic protection; neither reflects a ruleset. "All three allowed"
is not evidence a method will be accepted. Read the ruleset before any merge:

```bash
gh api repos/{owner}/{repo}/rulesets --jq '.[] | {id, name, target}'
gh api repos/{owner}/{repo}/rulesets/{id} \
  --jq '.rules[] | select(.type=="pull_request").parameters.allowed_merge_methods'
```

- Empty array (rc 0, `[]`) → no ruleset governs the repo; only then do the
  repo-level fields describe effective policy.
- `allowed_merge_methods` is authoritative where present. A method absent from it
  is a hard stop, not a fallback candidate — surface the restriction to the user
  *before* merging rather than discovering it when the merge is refused.

**Resolve the exact repo name before any GraphQL `$owner`/`$repo` call.** URL
slugs normalize underscores to hyphens, but the GraphQL API requires the stored
name verbatim — a slug-derived name (from a URL or `$GITHUB_ORG` search) returns
`NOT_FOUND`. Read it from the API; never derive it from a URL:

```bash
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
```

**Use the reactions API, not emoji text** — never embed emoji Unicode in reply
text as a substitute:
`gh api repos/{owner}/{repo}/pulls/comments/{id}/reactions -f content="+1"`.
Values: `+1 -1 laugh confused heart hooray rocket eyes`.

Every write surface must:

- Honor `$GITHUB_ORG` scoping per Step 1–2.
- Append outbound footer per Step 4 — no exceptions.
- Stay pending / drafted when the calling skill's contract is
  human-in-the-loop (self-review, pr-review). Never auto-submit on
  the user's behalf without explicit per-invocation consent.
