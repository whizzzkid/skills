# Merge Edge Cases

## Server-side stack flag → async merge fallback

`gh pr merge` may fail when GitHub's org-level stacked-PRs flags the PR
server-side, independent of local `gh stack view`. Fallback chain:
1. `gh pr merge --auto`
2. `gh stack merge {number} --yes --merge-method {method}`
3. Both classifier-blocked → surface `gh api repos/{owner}/{repo}/pulls/{number}/merge --method PUT -f merge_method={method}` for the user to run manually.

On user merge, re-run Step 1.

## Squash SHA citation warning

Squash collapses the branch into one new commit, so every per-branch SHA
recorded elsewhere becomes unreachable from the base. Before squashing a branch
whose individual commits are cited outside git (plan doc, PR body, tracking
issue), tell the user the citations will break and agree the remap first — a
squash-only repo makes this a hard constraint, not a preference.

## Host permission-classifier denial

**HARD RULE — distinct from branch protection.** A "Blocked by classifier" /
permission-layer denial of `gh pr merge` is NOT a non-zero merge error → do
**not** retry verbatim and do **not** fall back to another merge method (the host
layer blocks irreversible actions independent of the skill's own tool allowlist;
a different method is denied identically). Explain the two-layer model (skill
allowlist vs. host classifier) and that an explicit `Bash(gh pr merge:*)`
**settings.json** rule — or a manual user merge — is required to proceed.

A manual or past-tense merge by the user after denial IS the already-`MERGED`
path — re-run Step 1; on `state == "MERGED"`, resume Step 7. Never re-attempt.

## Post-merge read-only verification

Step 6's `gh pr view` / `gh pr checks` state polls are blocked by the auto-mode
classifier unless `Bash(gh pr view:*)` and `Bash(gh pr checks:*)` are in the
allowed tools — recommend adding both as a prerequisite. Run each read-only call
as a standalone invocation: an allow rule matches only when the allowed command
is the whole invocation, so a pipe to `grep`/`jq` or a compound (`&&`, e.g.
`rm … && gh pr view`) re-triggers the classifier. Do any grep/jq filtering in a
separate step (`--jq` is a `gh` flag, not a pipe → still matches).

## Squash rejected — self-review threads

`base branch policy prohibits the merge` and the only unresolved threads left
are the author's own self-review → this is the sole case that resolves them (not
a method fallback — merge-commit won't help). Ask the user first; on yes, mark
each resolved by `id`, then retry the squash:

```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -F id=<threadId>
```

Never auto-resolve self-authored threads without the user's explicit yes.

## Branch deletion

`--delete-branch` deletes the head branch after merge. Direct `/wk-pr-merge`
authorizes that documented default; `--keep-branch` opts out. Natural-language
merge request with no cleanup preference and disabled repository default → ask:
> "Delete the branch `{head}` after merge? (yes / no)"

## Merge verification poll

**HARD RULE — never declare "Merge complete" until `state == "MERGED"`.**
`gh pr merge --auto` and merge-queue repos return success while the PR is only
*queued*; an immediate state check returns `OPEN`. Poll until merged or ~60s
timeout:

```bash
for i in $(seq 1 12); do
  state=$(gh pr view {number} --repo "{repo_with_owner}" --json state --jq .state)
  [ "$state" = "MERGED" ] && break
  sleep 5
done
gh pr view {number} --repo "{repo_with_owner}" --json state,mergeCommit --jq '{state, mergeCommit: .mergeCommit.oid}'
```

Timeout (`state != "MERGED"`) → re-fetch blockers, stop, do **not** proceed to
Step 7 — never log a null SHA as success. Record `{merge_sha}` only once
`state == "MERGED"`.
