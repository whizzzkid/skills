# PR body extras

Two mechanical body-composition sub-steps relocated from `SKILL.md` Step 2 to
keep the skill under its size ceiling. Apply both when composing the PR body.

## Auto-populate stacked cross-reference links

When `$BEST_BASE` is another PR's head branch (the stacking signal from Step 1),
populate the `## Stack` cross-reference links from the detected ordering:

- Resolve each stack member's number/URL up front (`gh pr list --state open --json number,headRefName,baseRefName,url`), order by the base→head chain, and write canonical `[#NNN]({url})` prev/next links into the body **before** `gh pr create`.
- After creating the new PR, back-link it into the immediate parent: one `gh pr edit {parent}` adding this PR as its "next". Edit only the adjacent member, not the whole chain.
- A PR not yet created (later part) → list it as `pending` without a link; backfill when it exists.

## Markdown preview links

After composing the PR body, detect changed markdown files and append preview
links so reviewers can open the formatted view alongside the diff:

```bash
git diff "$BEST_BASE...HEAD" --name-only | grep '\.md$'
```

For each match, append to the PR body before posting:

```markdown
## Previews
- [Rendered preview: {filename}](https://github.com/{owner}/{repo}/blob/{branch}/{path})
```

Resolve `{branch}` from the head ref; skip when no `.md` files are in the diff.

## Incident-triggered bugfix body

When a linked PR/issue/outage/symptom surfaced the work:

- `## Why`/Summary must give the step-by-step of how the incident occurred (who did what, which API returned what, why the gate misfired), not only the abstract defect class — that chain is not in the diff, so narrate it here or it is lost.
- When the code change addresses only a related gap, not the symptom's root cause, put a prominent first-line Summary note: `Note: this does not fix {symptom}; that requires {out-of-code work, tracked in {ticket}}.`
- Burying either forces the reviewer to ask whether the change actually resolves the trigger.

## Rollout section for prod-facing diffs

Detect a prod-facing behavior change at composition time — the diff touches output posted to an external service/API, user-visible behavior, or a runtime gate.

- Include a `## Rollout` note proactively: flag/canary/staged vs. plain release, backward-compatibility, and rollback shape.
- Even a one-line "additive + backward-compatible, ships with the normal release, revert to roll back" satisfies a description-check bot and avoids a reactive post-create edit.
