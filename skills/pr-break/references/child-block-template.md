# Child Block Template

Per-child plan block format and stack overview table used in Stage 4.

## Child Block

```
### Child PR {n}/{N}: <conventional-subject> (~<size hint>)

**Stack position:** Built on top of {parent} (#parent or "main").
**Scope:** <one-paragraph user-visible description>.
**Files touched:** <list of paths or globs>; net diff ~<lines>.
**Builds / tests in isolation:** <yes — what verifies it>.
**Depends on:** <prior children in the stack, or "none">.
**Blocks:** <subsequent children, or "none">.
**Follow-up:** <deferred work this PR explicitly does not include>.
**Reviewer note:** <one sentence on why this is the natural seam>.
```

## Stack Overview Table

```
1. <subject>            (~80 LOC)   — refactor, no behavior change
2. <subject>            (~120 LOC)  — primitive on top of (1)
3. <subject>            (~200 LOC)  — feature wired through primitive
4. <subject>            (~40 LOC)   — cleanup of legacy code path
```

Every child PR's draft description must mention:

- **Stack** — links to the parent (and ultimately the original PR).
- **Blockers** — what merges before this can merge (the `Depends on` line).
- **Follow-up** — what this PR explicitly defers, with links to the child PR(s) that pick it up, or a TODO with a tracking ticket if the follow-up is post-stack.

This matches `wk-pr`'s description template (Step 2 there); the `wk-pr-break` plan **populates** that template for each child.

## Annotation Routing

Extract annotations from Stage 1 (title, body, comments, commit trailers) and route each to the appropriate child. When in doubt, include rather than drop.

| Annotation | Routing |
|------------|---------|
| `Closes #N` / `Fixes #N` | **Final child only** — earlier children carry `Refs #N`. |
| `Refs #N` / `Related to #N` | Every child touching code in the issue's scope. |
| `[BOARD-NUM]` Jira key | Every child's title (umbrella ticket; `wk-jira` transitions on final child). |
| Design doc / RFC / spec URL | Every child — reviewers of any slice need the design context. |
| Deploy / migration callout | The child that introduces the dependency, and the final child. |
| Linked demo / screenshot / Loom | The user-visible feature child (usually last). |
| `Co-Authored-By:` trailers | Commits that ship the corresponding work, per original mapping. |

For each child block, add an **Annotations** subsection so the user can audit routing:

```
**Annotations propagated:**
- Refs #NNN (Closes moves to final child)
- Spec: docs/specs/feature-x.md
- [BOARD-NUM] Jira suffix on title
```
