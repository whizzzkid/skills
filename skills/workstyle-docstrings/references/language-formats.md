# Language-Native Docstring Formats

For every public callable with a doc comment, verify it documents inputs and
outputs. Use the language-native format; fill only what exists (skip `@param`
if no params, skip `@returns` if `void`/`None`/`unit`).

## Formats by language

| Language | Format | Example |
|----------|--------|---------|
| TypeScript/JS | JSDoc `@param {Type} name` / `@returns {Type}` | `/** @param {string} id @returns {Promise<User>} */` |
| Python | Google-style docstring or NumPy-style; never both | `Args: id (str): ... Returns: User` |
| Go | `//` doc comment above `func`; first sentence is the summary | `// FetchUser returns the User for the given id, or ErrNotFound.` |
| Ruby | YARD `@param name [Type]` / `@return [Type]` | `# @param id [String] @return [User, nil]` |
| Rust | `///` for public items; `//!` for modules; use backtick for types | `` /// Returns the [`User`] for `id`, or [`None`] if absent. `` |
| Java/Kotlin | JavaDoc `@param` / `@return` / `@throws` | standard JavaDoc blocks |
| Shell | `# Args: $1 -- description` above the function | inline `# Args:` block |

## Summary line rule

One-sentence summary first, then params/returns. Do not write a multi-paragraph
summary -- if more than one sentence is needed, the function needs to be split.

## Stale comment removal (mandatory)

When editing code, scan the entire function or block for adjacent comments that
no longer match:

```bash
# After renaming a parameter, grep for the old name in comments
grep -n "old_param_name" <file>
```

- Old parameter names, removed return types, stale behavior descriptions: delete.
- Outdated `@param` for a removed parameter is a blocker -- it misleads callers.
- Comment describing behavior the code no longer implements: delete or update.
