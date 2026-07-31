---
skill: wk-gh
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

A required status context with no run on HEAD blocks the merge as an absence, not a failure.

**What happened:** A PR showed every visible check green and `mergeStateStatus: BLOCKED`.
`gh pr merge --squash` failed with "the base branch policy prohibits the merge". The repo's
ruleset listed one more required context than the CI workflow produces — an automated
code-review bot's context. That bot's rule had `review_on_push: false`, so it never re-ran
after later pushes and the required context had **no check-run at all** on HEAD. Nothing was
red; something was simply missing, which no green-checks review surfaces.

Neither documented path to request a run works for a bot reviewer:

- `POST /repos/{owner}/{repo}/pulls/{n}/requested_reviewers` → `422 Reviews may only be
  requested from collaborators`.
- The GraphQL mutation for requesting an automated review does not exist on the schema.

The user resolved it manually in the web UI.

**Root cause:** Merge-readiness was diagnosed by asking "is any check failing?" rather than
"does every required context have a conclusion on HEAD?" The two questions differ precisely
when a required context is produced by something other than the CI workflow.

**Suggested fix:** Add a diagnostic step for a `BLOCKED`-with-green-checks PR:

1. Read the ruleset's `required_status_checks` contexts —
   `gh api repos/{owner}/{repo}/rulesets/{id} --jq '.rules[] | select(.type=="required_status_checks")'`.
   Do not use `branches/{branch}/protection`; it 404s on a ruleset-governed repo.
2. Read the conclusions on HEAD —
   `gh api repos/{owner}/{repo}/commits/{sha}/check-runs --jq '.check_runs[].name'`.
3. Set-difference the two. A required context absent from the second list is the blocker.
4. When the missing context belongs to an automated reviewer, say so plainly and hand it to
   the user — there is no supported API to trigger it. Do not burn attempts on the
   `requested_reviewers` or GraphQL paths.
