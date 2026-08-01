# Ticket transition mechanics

Detect ticket references from the PR title, branch, and body. Before scanning
the body, strip only the terminal canonical footer from
[`wk-gh`](../../gh/README.md) Step 4:

```bash
body_without_footer="$(
  awk '
    { line[NR] = $0 }
    END {
      end = NR
      if (line[end] ~ /^<sup>Generated using \[wk-skills\]\([^)]+\) and multiple agents\/models\. DM me your feedback\.<\/sup>$/) {
        end--
        if (end > 0 && line[end] == "---") end--
        if (end > 0 && line[end] == "") end--
      }
      for (i = 1; i <= end; i++) print line[i]
    }
  ' < <(printf '%s\n' "$body")
)"
```

Do not truncate at the first `---`: PR prose may contain horizontal rules. Only
the exact terminal footer line and its adjacent separator/blank line are
metadata.

```bash
# Jira: boundary-delimited [A-Z][A-Z0-9]+-[0-9]+ tokens only
awk '
  {
    rest = $0
    while (match(rest, /[A-Z][A-Z0-9]+-[0-9]+/)) {
      key = substr(rest, RSTART, RLENGTH)
      before = RSTART > 1 ? substr(rest, RSTART - 1, 1) : ""
      after = substr(rest, RSTART + RLENGTH, 1)
      if ((before == "" || before !~ /[[:alnum:]_]/) &&
          (after == "" || after !~ /[[:alnum:]_]/) &&
          !seen[key]++) {
        print key
      }
      rest = substr(rest, RSTART + RLENGTH)
    }
  }
' < <(printf '%s\n' "$title" "$branch" "$body_without_footer")

# GitHub issues: closes/fixes/resolves #N annotations
printf '%s\n' "$body_without_footer" | grep -ioE '(closes?|fixes?|resolves?)[[:space:]]+#[0-9]+'

# Asana: app.asana.com URLs
printf '%s\n' "$body_without_footer" | grep -oE 'https://app\.asana\.com/[^[:space:]]+'
```

The Jira boundary check rejects matches embedded in timestamps, URLs,
model/version strings, or larger identifiers while preserving keys surrounded
by punctuation or branch-name separators.

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
