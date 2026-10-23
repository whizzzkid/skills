# Combined PR body template

Body for `SKILL.md` § Step 5. One table row per applied Dependabot PR; one `Closes #N` per superseded PR.

```markdown
## Combined Dependency Updates

Batches the following Dependabot PRs into a single update:

| PR | Package | Version |
|----|---------|---------|
| #<N> | <package> | <old> → <new> |
...

### Major-bump audit
| Package | Direct/transitive | Version (up/down) | Breaking + default-behavior changes vs app usage |
|---------|-------------------|-------------------|--------------------------------------------------|
| <package> | transitive | <old> → <new> | <verdict; defaults restored explicitly, if any> |
(None → "No major-version changes, up or down, direct or transitive.")

### Superseded PRs
Closes #<N1>, #<N2>, #<N3>, ...

### Post-merge cleanup
GitHub auto-closes PRs referenced by `Closes #N` on merge.
Verify closed state; if any remain open: `gh pr close <N> --delete-branch --comment "Superseded by #<this_PR>"`
Or invoke `/wk-renovate cleanup` to handle stragglers.
```
