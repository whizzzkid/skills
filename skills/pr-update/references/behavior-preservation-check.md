# Behavior-Preservation Check

Tests passing is necessary but **not sufficient** — when both production code and its
spec are picked from the same side of a conflict, the regression is internally
consistent and CI does not catch it.

For every file touched by the integration, diff the integrated result against the
pre-integration base:

```bash
git diff "$START_SHA"..HEAD -- <file>
```

Scan for removed lines in these high-risk categories:

| Category | Examples |
|----------|---------|
| Environment lookups | `ENV.fetch`, `process.env`, `os.environ` |
| Fallback chains | `if x.nil?`, `x || default`, `?? fallback` |
| Error handling | `rescue`, `catch`, `try/except`, `.on_error` |
| Guards / early returns | `unless`, `return if`, `if !x` |
| Spec coverage | removed `it` / `test` / `describe` blocks |

If a removed line's behavior appears nowhere else in the diff, surface
it:

> "Line removed: `{line}` — behavior `{description}` now has no owner.
> Was this intentional?"

Do not push if the user has not answered. A pure integration's net diff should be
narrow; large unexplained deletions warrant line-by-line review, not just a passing test
suite.
