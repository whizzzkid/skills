---
name: wk-gh
description: >-
  Activates whenever the agent uses the gh CLI or interacts with GitHub
  PRs, issues, or notifications. Ensures all GitHub operations are scoped
  to the user's organization via $GITHUB_ORG. Prompts the user to set
  the variable if missing.
model-invocable: true
user-invocable: false
model: sonnet
effort: low
license: MIT
group: tools
env-vars:
  - GITHUB_ORG
metadata:
  author: whizzzkid
  version: '2026.07.10-230918'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# GitHub Organization Scope

Ensures all `gh` CLI and GitHub interactions are scoped to the user's
organization. Activates automatically when the agent is about to run any
`gh` command or interact with GitHub PRs, issues, or notifications.

**HARD RULE — no size or surface exemption.** Every `gh` write
fires this skill: `gh pr create`, `gh pr edit`, `gh pr comment`,
`gh issue comment`, `gh api` POST/PATCH/DELETE, `gh pr review`,
reply posts, thread resolutions. "It's just a comment" / "it's
one-line" / "the user asked for it inline" are not bypass criteria.
Read-only `gh` calls (`view`, `diff`, `search`, `api` GET) still
honor Step 1–2 scoping but skip Step 4 (no body to footer).

## Step 1: Check for $GITHUB_ORG

Run `echo "${GITHUB_ORG:?}"` before any `gh` command.
- **Missing/empty:** STOP — prompt the user to run `export GITHUB_ORG=your-org-name`; do not guess or infer from the current repo.
- **Set:** proceed to Step 2.

## Step 2: Scope All Commands

Once `$GITHUB_ORG` is confirmed, apply the org filter to every `gh`
command:

### Search commands

Add `--owner=$GITHUB_ORG` to all `gh search` commands:

```bash
# PRs
gh search prs --owner="$GITHUB_ORG" --review-requested=@me --state=open ...
gh search prs --owner="$GITHUB_ORG" --author=@me --state=open ...

# Issues
gh search issues --owner="$GITHUB_ORG" --assignee=@me --state=open ...
```

### Notifications

Filter notifications to the org:

```bash
gh api notifications --jq ".[] | select(.repository.owner.login == \"$GITHUB_ORG\") | ..."
```

### Issue/PR creation

No special filtering needed — these operate on the current repo. But
if the current repo is not in `$GITHUB_ORG`, warn the user:

```bash
CURRENT_ORG=$(gh repo view --json owner --jq '.owner.login')
if [ "$CURRENT_ORG" != "$GITHUB_ORG" ]; then
  echo "Warning: current repo ($CURRENT_ORG) is not in $GITHUB_ORG"
fi
```

## Exceptions

The org scope is **not applied** when:

- The user explicitly names a different org or repo (e.g., "check
  PRs on `other-org/repo`")
- The user says "all orgs", "everywhere", or "across all repos"
- The command targets the current repo specifically (e.g., `gh pr view`)

In all other cases, default to `$GITHUB_ORG`.

## Step 3: Canonical surface for GitHub writes

Every skill that creates or edits GitHub-visible content routes
through this skill's conventions. Read-only `gh` calls (view, diff,
search, api GET) do not require this routing — only writes.

Surfaces covered (non-exhaustive):

- PR title and body (`gh pr create`, `gh pr edit`)
- Review body and inline review comments (`gh api .../pulls/{n}/reviews`)
- Inline-comment replies (`gh api .../pulls/{n}/comments/{id}/replies`)
- Issue and PR conversation comments (`gh issue comment`, `gh pr comment`)
- Review-thread state changes (resolve/unresolve via GraphQL)

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
("is not a number").

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

**Resolve the exact repo name before any GraphQL `$owner`/`$repo` call.** URL
slugs normalize underscores to hyphens, but the GraphQL API requires the stored
name verbatim — a slug-derived name (from a URL or `$GITHUB_ORG` search) returns
`NOT_FOUND`. Read it from the API; never derive it from a URL:

```bash
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
```

Every write surface above must:

- Honor `$GITHUB_ORG` scoping per Step 1–2.
- Append the outbound footer per Step 4 — no exceptions for short
  comments, draft reviews, or PR descriptions.
- Stay pending / drafted when the calling skill's contract is
  human-in-the-loop (self-review, pr-review). Never auto-submit on
  the user's behalf without explicit per-invocation consent.

## Step 4: Outbound message footer

**HARD RULE — Important:** Every message this agent posts to GitHub on the
user's behalf must end with the canonical footer below, verbatim. The footer
attributes the automation and gives the user a feedback channel —
silent posts erode trust and make automated activity hard to audit.

- **The footer covers every agent-authored outbound body — not only GitHub.**
  Any body this agent composes for an external system carries this canonical
  footer: Jira issue/comment bodies (MCP `addCommentToJiraIssue`/
  `editJiraIssue`), Slack messages, doc bodies. The owning skill injects it at
  render time; a non-GitHub write path is not an exemption. A terse factual
  status line (lifecycle comment) is still an outbound body — it carries the
  footer too.
- **Paste the literal footer block below into the payload at render time —
  never hand-write or paraphrase the attribution.** Composing an ad-hoc
  string (e.g. a `Assisted by Claude Code (model)` line) at payload-build
  time defeats the verbatim guarantee and ships a non-canonical footer.
  Read this block from the skill and inject it; do not reconstruct it from
  memory.
- **The commit-message footer is a DIFFERENT string — never ship it on a
  GitHub/outbound body.** The `wk-commit` trailer (`🦾 Generated with
  [wk-skills](...) and multiple models.`) belongs only in commit messages and
  PR-body trailers; both footers open with "Generated ... wk-skills", so the two
  are easy to conflate — type neither from memory.
- **Pre-emit gate — run mechanically on EVERY outbound body before posting, no
  exceptions.** A footer defect on one surface is almost always on every body
  posted the same way, so sweep all surfaces (PR body, review bodies, every
  comment/reply) in one pass. For each body string:
  ```bash
  grep -qF 'DM me your feedback.</sup>' <<<"$body" || echo "REJECT: canonical footer absent"
  grep -qF '🦾 Generated with' <<<"$body" && echo "REJECT: commit-trailer variant present"
  ```
  A REJECT on either line blocks the post — fix the footer and re-check before writing.

```
---
<sup>Generated using [wk-skills](https://github.com/whizzzkid/skills) and multiple agents/models. DM me your feedback.</sup>
```

Apply to:

- PR descriptions (body of `gh pr create` and `gh pr edit`).
- Review bodies (the top-level `body` of a `/pulls/{n}/reviews` POST).
- Inline review comments (each entry's `body` in the `comments[]`
  array — the footer goes at the end of the comment body).
- Conversation comments on PRs and issues.
- Replies to existing review threads.

Footer placement rules:

- Footer is the **last** content in the message. Nothing follows it.
- Separate from prior content with a blank line above the `---`.
- When the calling skill already specifies a richer footer (e.g.,
  `wk-commit` PR-body sync footer, `wk-pr-review` review-body
  closing line), append this footer **after** the skill-specific
  one — never replace the skill-specific footer.
- When editing an existing PR body that already contains this
  footer, do not duplicate it — re-emit the body with the footer
  appearing exactly once at the end.

Exceptions:

- Suggestion fences (` ```suggestion `) embedded inside a comment
  body do not carry the footer themselves; the footer applies to
  the enclosing comment.
- Resolution / state-change mutations (resolving a thread, marking
  a PR ready, merging) carry no message body and are exempt.

If the calling skill emits a payload via a template (heredoc, file,
jq construction), inject the footer at template-render time so a
forgotten append cannot ship a footer-less message.

## Canonical download path

For artifact download paths, see `skills/buildkite/SKILL.md` — the pattern is
identical (`/tmp/agent/<tool>/<resource>/...`). The `gh`-specific root is
`/tmp/agent/gh/<owner>/<repo>/<resource_type>/<resource_id>/<filename>`.

Apply `--owner=$GITHUB_ORG` filtering to all `gh search` and `gh api
notifications` calls when writing artifacts to ensure the path namespace
stays org-scoped.

## Quick Reference

| Scenario | Behavior |
|----------|----------|
| `$GITHUB_ORG` set | Add `--owner=$GITHUB_ORG` to search commands |
| `$GITHUB_ORG` missing | Stop and prompt user to set it |
| User names a different org | Use that org instead |
| User says "all orgs" | Skip org filter |
| Current-repo commands | No filter needed |
| Saving any `gh` payload to disk | Use `/tmp/agent/gh/<owner>/<repo>/...` |
| Any outbound GitHub message | Append canonical footer (Step 4) — once, last |
| Calling skill writes to GitHub | Route the write through this skill's Step 3/4 |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn gh`).
