---
skill: wk-pr
date: 2026-07-27
type: correction
severity: high
verified-against-source: n/a
---

A CI run id written into the PR body's test-plan checkbox was invented rather than queried, producing a link to a run that does not exist.

**What happened:** While re-checking the CI checkbox after a force-push, the agent wrote a
plausible-looking numeric run id into the PR body without having read it from any command output.
Self-caught one step later by running `gh pr checks {n}` and
`gh run list --branch <branch> --json databaseId,headSha,conclusion`, which returned a different,
real id; the body was corrected.

**Root cause:** The body-sync step treats the checkbox as prose to update, so the run id was
reconstructed from context like the surrounding sentence rather than fetched. Nothing in the sync
step requires the identifier to come from a command run in that same turn.

**Suggested fix:** Make it explicit in the CI-green body-sync step that every run id, SHA, count,
and artifact URL written into a PR body must be pasted from output of a command executed in that
same response — `gh run list --json databaseId,headSha,conclusion` for run ids, `git rev-parse`
for SHAs. A remembered or reconstructed identifier is fabrication even when the rest of the
sentence is true. This is a recurrence of the same failure class already captured for other
surfaces, so the rule belongs on the body-sync step itself, not only in review skills.
