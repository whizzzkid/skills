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
  - GH_TOKEN
  - GITHUB_TOKEN
metadata:
  author: whizzzkid
  version: "2026.08.28-201131"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# GitHub Organization Scope

Ensures all `gh` CLI and GitHub interactions are scoped to the user's organization. Activates before any `gh`
command or GitHub PR, issue, or notification interaction.

**HARD RULE — no size or surface exemption.** Every `gh` write
fires this skill: `gh pr create`, `gh pr edit`, `gh pr comment`,
`gh issue comment`, `gh api` POST/PATCH/DELETE, `gh pr review`,
reply posts, thread resolutions. "It's just a comment" / "it's
one-line" / "the user asked for it inline" are not bypass criteria.
Read-only `gh` calls (`view`, `diff`, `search`, `api` GET) still
honor Step 1–2 scoping but skip Step 4 (no body to footer).

## Step 0: Select stored vs environment credentials

- `GH_TOKEN`, then `GITHUB_TOKEN`, take precedence over stored credentials. Never print or inspect token values.
- User explicitly confirms stored/keyring authentication → preserve the login-shell environment, but remove both
  token variables at every final `gh` command boundary. Skip `gh auth status` and credential refresh:

  ```bash
  env -u GH_TOKEN -u GITHUB_TOKEN gh ...
  ```

- Authorization fails unexpectedly without explicit stored-auth confirmation → compare normal and token-unset status
  before refreshing credentials:

  ```bash
  gh auth status
  env -u GH_TOKEN -u GITHUB_TOKEN gh auth status
  ```

- Token-unset form reaches the expected account/host → rerun only the affected command with both variables removed.
  Do not mutate login state or credential configuration.

## Step 1: Check for $GITHUB_ORG

Run `echo "${GITHUB_ORG:?}"` before any `gh` command.
- **Missing/empty:** STOP — prompt `export GITHUB_ORG=your-org-name`; never infer it from the current repo.
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

No special filtering needed — warn if current repo not in `$GITHUB_ORG`:

```bash
CURRENT_ORG=$(gh repo view --json owner --jq '.owner.login')
if [ "$CURRENT_ORG" != "$GITHUB_ORG" ]; then
  echo "Warning: current repo ($CURRENT_ORG) is not in $GITHUB_ORG"
fi
```

## Exceptions

The org scope is **not applied** when:

- The user explicitly names a different org or repo (e.g., "check PRs on `other-org/repo`")
- The user says "all orgs", "everywhere", or "across all repos"
- The command targets the current repo specifically (e.g., `gh pr view`)
- `gh pr view --repo` requires a positional PR: pass `<number-or-url>` before `--repo` for `--web`; omit `--repo`
  when relying on current-branch inference.

### Variable-dependent jq projections

- `gh --jq` accepts one expression and no standalone `jq` flags (`--arg`, `--argjson`).
- Constant projection → keep `gh --jq`:

  ```bash
  gh pr view --json headRefOid --jq '.headRefOid'
  ```

- Projection needs shell values → pipe raw `--json` to standalone `jq`:

  ```bash
  gh pr view --json headRefOid \
    | jq --arg expected "$expected_sha" 'select(.headRefOid == $expected)'
  ```

- Quote complete `gh api` endpoints containing shell metacharacters (`?`, `&`, `*`) → prevent zsh globbing.

## Stack topology vs live pull-request state

- Treat `gh stack view --json` as topology and membership data; its
  `branches[].head` comes from persisted local stack state and can lag the remote
  pull-request head.
- Resolve each pull request’s live `headRefOid` with
  `gh pr view <number> --json headRefOid` immediately before CI or merge gates;
  never substitute `branches[].head`.

## Step 3: Canonical surface for GitHub writes

All GitHub write operations (PR create/edit, review comments, inline replies,
issue comments, thread state changes) route through this skill. Build JSON bodies
with `jq -n`, never heredocs. Check for pending reviews before GraphQL replies.
Resolve repo names from the API, not URLs. Use the reactions API for emoji responses.

Full API surface rules, endpoint gotchas, and pending-review guards:
[`references/github-api-surfaces.md`](references/github-api-surfaces.md).

## Step 4: Outbound message footer

**HARD RULE:** Every agent-authored outbound body (GitHub, Jira, Slack, docs)
must end with the canonical footer verbatim. Paste the literal block at render
time — never hand-write or paraphrase. The commit-message footer is a DIFFERENT
string; never ship it on an outbound body.

```
---
<sup>Generated using [wk-skills](https://github.com/whizzzkid/skills/tree/main@%7B<UTC>%7D) and multiple agents/models. DM me your feedback.</sup>
```

Pin `<UTC>` to render-time (`date -u +%Y-%m-%dT%H:%M:%SZ`). Run the pre-emit
gate on every body before posting. Full placement rules, scope, pre-emit gate
bash, and exceptions: [`references/footer-gate-details.md`](references/footer-gate-details.md).

## CI Status and Merge Readiness

`statusCheckRollup` is a heterogeneous union — inspect both `.status`/`.conclusion`
(CheckRun) and `.state` (Status). `gh pr checks --watch` is not proof of green;
re-query the full rollup after exit. `BLOCKED` with green checks → compare
ruleset `required_status_checks` against rollup names.

Full rollup union rules, superseded-run handling, `--json` schema differences,
BLOCKED diagnosis, and workflow-run gate:
[`references/status-check-rollup.md`](references/status-check-rollup.md).

## Canonical download path

[`references/canonical-download-path.md`](references/canonical-download-path.md).

## Quick Reference

| Scenario | Behavior |
|----------|----------|
| Stored/keyring auth explicitly confirmed | Run every `gh` command with `GH_TOKEN` and `GITHUB_TOKEN` unset; skip auth inspection |
| Unexpected authorization failure | Compare normal and token-unset `gh auth status` before credential refresh |
| `$GITHUB_ORG` set | Add `--owner=$GITHUB_ORG` to search commands |
| `$GITHUB_ORG` missing | Stop and prompt user to set it |
| User names a different org | Use that org instead |
| User says "all orgs" | Skip org filter |
| Current-repo commands | No filter needed |
| Projection needs variables | Pipe raw `gh --json` output to standalone `jq --arg`; never pass `--arg` after `gh --jq` |
| Saving any `gh` payload to disk | Use `/tmp/agent/gh/<owner>/<repo>/...` |
| Stack topology vs gate SHA | Use stack JSON for membership; resolve live `headRefOid` with `gh pr view` |
| Any outbound GitHub message | Append canonical footer (Step 4) — once, last |
| Calling skill writes to GitHub | Route the write through this skill's Step 3/4 |

---
