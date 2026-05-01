---
name: wk:gh
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
metadata:
  author: whizzzkid
  version: '2026.05.01-073751'
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

## Step 1: Check for $GITHUB_ORG

Before running any `gh` command, verify that `$GITHUB_ORG` is set:

```bash
echo "${GITHUB_ORG:?}"
```

### If $GITHUB_ORG is missing or empty

**STOP.** Do not run the `gh` command. Prompt the user:

> "`$GITHUB_ORG` is not set. All GitHub operations are scoped to your
> org to avoid noise from forks and personal repos.
>
> Please set it:
> ```
> export GITHUB_ORG=your-org-name
> ```
>
> Or run `! export GITHUB_ORG=your-org-name` in this session."

**Do not proceed until `$GITHUB_ORG` is set.** Do not guess or infer
the org name from the current repo — it must be explicitly set by the
user.

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

## Canonical download path

When saving any GitHub artifact to disk — API response bodies, PR body
drafts, review payloads, workflow run logs, issue comment dumps — write
to a structured, namespaced path rather than an ad-hoc `/tmp/<name>`.

```
/tmp/agent/gh/<owner>/<repo>/<resource_type>/<resource_id>/<filename>
```

| Resource | Example path |
|---|---|
| PR body draft | `/tmp/agent/gh/<owner>/<repo>/pulls/<n>/body.md` |
| Self-review payload | `/tmp/agent/gh/<owner>/<repo>/pulls/<n>/self_review.json` |
| Issue comments | `/tmp/agent/gh/<owner>/<repo>/issues/<n>/comments.json` |
| Workflow run log | `/tmp/agent/gh/<owner>/<repo>/runs/<run_id>/log.txt` |

Run `mkdir -p` on the directory before writing. The structure namespaces
parallel work across multiple PRs/repos, prevents cross-session
overwrites of identically-named scratch files, and provides a
greppable audit trail (`ls /tmp/agent/gh/<owner>/<repo>/pulls/`).

This convention is shared across every skill that downloads from an
external system — see `wk:buildkite` for the matching path.

## Quick Reference

| Scenario | Behavior |
|----------|----------|
| `$GITHUB_ORG` set | Add `--owner=$GITHUB_ORG` to search commands |
| `$GITHUB_ORG` missing | Stop and prompt user to set it |
| User names a different org | Use that org instead |
| User says "all orgs" | Skip org filter |
| Current-repo commands | No filter needed |
| Saving any `gh` payload to disk | Use `/tmp/agent/gh/<owner>/<repo>/...` |

---

## Post-Completion

Invoke `wk:learn` with this skill's short name as the argument (e.g., `wk:learn gh`).
