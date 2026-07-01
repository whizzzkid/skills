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
