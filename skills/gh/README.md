# wk-gh

> Ensures all `gh` CLI and GitHub interactions are scoped to the user's organization via `$GITHUB_ORG`.

**Version:** `2026.07.31-013640`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | Not user-invocable |
| Model-invocable | automatic on: any `gh` CLI command, GitHub PR/issue/notification interaction |

## How It Works

```mermaid
flowchart TD
    A[Agent about to run gh command] --> B{$GITHUB_ORG set?}
    B -- No --> C[STOP — prompt user to export GITHUB_ORG=org-name]
    B -- Yes --> D{User named a different org?}
    D -- Yes --> E[Use that org instead]
    D -- No --> F{User said all orgs?}
    F -- Yes --> G[Skip org filter]
    F -- No --> H[Apply --owner=$GITHUB_ORG to search commands]
    H --> I[Filter notifications to org via jq select]
    I --> J{Current repo in $GITHUB_ORG?}
    J -- No --> K[Warn: current repo is not in GITHUB_ORG]
    J -- Yes --> L[Proceed]
```

## Noteworthy

- **Hard stop on missing var:** The skill never guesses the org from the current repo URL — if `$GITHUB_ORG` is unset, all `gh` operations halt and the user is prompted to set it explicitly.
- **Exceptions are explicit:** The org filter is bypassed only when the user names a different org, says "all orgs", or the command targets the current repo directly (e.g., `gh pr view`).
- **Artifact download path:** Files saved from `gh` commands go to `/tmp/agent/gh/<owner>/<repo>/<resource_type>/<resource_id>/<filename>` — mirrors the Buildkite convention.
- **Notification filtering uses `jq`:** Org-scoping for `gh api notifications` is applied via `.repository.owner.login == "$GITHUB_ORG"` in a jq filter, not a CLI flag.
- **Point-in-time footer link:** The canonical outbound footer's [wk-skills](https://github.com/whizzzkid/skills) link pins to `tree/main@%7B<UTC>%7D` — a render-time UTC timestamp — so readers see the skills as they were when the message posted, not moving HEAD.
- **Rollup union rules sit in their own section:** `Reading statusCheckRollup` is placed ahead of the `--watch` guidance and applies to every consumer — the watch subcommand, a hand-rolled `until` poll, or a one-shot readiness check. CheckRun nodes carry `.status`/`.conclusion`; commit Status nodes carry `.state` with `.status == null`, so a filter over one field alone reports green while a pending status context is still building.
- **Rollup granularity:** `statusCheckRollup` has one entry per registered check, not per pipeline job — it answers "is the pipeline green", never "did that specific job pass"; a per-job claim must cite the CI provider's per-job view and exit status.
- **A never-triggered workflow has no run to read:** a job whose `on:` triggers exclude the current ref never executes, so it must not be marked complete, documented as green, or added to required status checks until `gh run list --branch <ref>` shows a run for that ref — an unexecuted gate is not a gate.
- **Green visible checks can still omit a required context:** when merge state is
  blocked, compare ruleset requirements against the current HEAD rollup; an
  absent context is a blocker without a failure.
- **Model-invocable only:** This skill is a guard rail, not a user command — it fires silently alongside any other skill that uses `gh`.
