# Ticket transition mechanics

Detect ticket references from the PR title, body, and branch name:

```bash
# Jira: any [A-Z][A-Z0-9]+-\d+ token
echo "{title} {branch} {body}" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+'

# GitHub issues: closes/fixes/resolves #N annotations
echo "{body}" | grep -ioE '(closes?|fixes?|resolves?)\s+#[0-9]+'

# Asana: app.asana.com URLs
echo "{body}" | grep -oE 'https://app\.asana\.com/[^[:space:]]+'
```

## Jira tickets

For each detected Jira key:

1. Fetch issue + available transitions:
   ```
   getJiraIssue(key)
   getTransitionsForJiraIssue(key)
   ```
2. Find the terminal transition (first match among: `Done`, `Closed`,
   `Resolved`, `Shipped`, `Complete`).
3. Transition:
   ```
   transitionJiraIssue(key, transitionId)
   ```
4. Post a shipped comment:
   ```
   addCommentToJiraIssue(key,
     body="Shipped in PR #{number} — {title}.\n{merge_sha}\n\nSee: {url}")
   ```

No terminal transition found → note in output, skip the transition, do not
block the merge.

**Jira MCP unavailable / unauthenticated** (connector tools error or absent) →
do not block the merge. Surface the detected key and its terminal state in the
Step 8 follow-ups for manual transition, mirroring the Asana fallback:

> "⚠️ Jira MCP unavailable — transition `<KEY>` to Done manually: {url}"

## GitHub issues

For each `closes #N` / `fixes #N` reference:

```bash
gh issue close {N} --comment "Shipped in {url} (merge commit {merge_sha})."
```

GitHub auto-close via `Closes #N` only fires when the PR merges into the repo's
default branch. For other base branches, close manually here.

## Asana

No MCP available for Asana. Note each detected URL in the follow-ups output so
the user can transition manually:

> "⚠️ Asana task detected — no MCP available. Transition manually: {url}"

## No ticket found

No ticket key or issue reference found anywhere → note it, continue, do not
block.
