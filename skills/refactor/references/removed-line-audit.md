# Removed-Line Audit Checklist

For each modified file, walk every removed line and classify as:

- **Relocated** -- same logic under a new name/file/function. Note where.
- **Subsumed** -- a generic helper now handles this case. Confirm coverage.
- **Intentionally removed** -- PR description or commit message documents it.
- **Suspicious** -- none of the above. Flag for surfacing.

## Mandatory checks per removed line shape

| Removed line shape | Question |
|--------------------|----------|
| `ENV.fetch(...)` / `os.environ[...]` / `process.env.X` | Is the env var still read somewhere with the same default / missing-key behavior? |
| Fallback chain (`x \|\| y`, `if a.nil? then b`, optional-chaining defaults) | Is the fallback still invoked when the primary is unset? Default value preserved? |
| `rescue` / `catch` / `except` clause | Is the exception still caught somewhere up-stack? Or intentionally allowed to propagate? |
| Guard (`return early`, `unless`, `if not allowed`, validation) | Is the guarded condition now structurally impossible, or just unguarded? |
| Comment documenting *why* a branch existed | If the branch was removed, was the reason still relevant? |
| Conditional selecting between two valid paths | Was the unselected path documented elsewhere? Is selecting one always correct? |
| Call site of an external API / CLI / DB query | Is that call now made elsewhere, with same arguments and error handling? |
| A test (deleted or renamed) | Does an equivalent assertion exist on the new shape? |
| `warn`/`logger.*`/`puts`/`console.*`/`log.*` in a removed block | Is the diagnostic still emitted on the same code path? Guard-clause collapse routinely drops warnings. |
| Behavior narrowed to a specific arm/mode/branch | Do all existing tests still drive the unit through the arm that now owns the behavior? |

A removed line the refactor's kind does NOT predict (e.g. `ENV.fetch` removal
during a rename) = suspicious by default.

## Stale-literal check

Runs when a refactor replaces a named constant with a resolver whose return
value differs from the former literal:

- Grep the **old literal value** across all files -- not just the identifier.
- Identifier-grep misses hardcoded copies in string-literal contexts.
- Every hit that is not a comment or test fixture must use the resolver's return value.
- Failure mode: stale literal in an error message shows users wrong/outdated value.
