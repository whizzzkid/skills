# Integration Strategy Selection

**HARD RULE — merge is the default integration strategy.** Use `git merge "$BASE_REF"`
unless the commit count makes per-commit conflict resolution painful or the user
explicitly asks for clean linear history. Rebase rewrites SHAs, requires force-push, and
loses review-thread anchoring; merge preserves all three.

| `$AHEAD` | Strategy | Why |
|----------|----------|-----|
| **HEAD already has a base-merge, recomputed `$AHEAD ≤ 5`** | `git merge "$BASE_REF"` | Merge-style branch — preserve the merge topology; do not squash already-reviewed commits. |
| **< 5** (no prior base-merge) | `git merge "$BASE_REF"` | Default. Preserves commit SHAs, avoids force-push, keeps review threads anchored. |
| **≥ 5** (no prior base-merge) | Patch-replay | Large commit count → rebasing N commits is N conflict-resolutions; one patch is one. Commit messages are reconstructed from the squashed subject + a body listing the original SHAs for traceability. |
| **≥ 5** but **PR is ready-for-review** (`isDraft = false`) | `git merge "$BASE_REF"` | Override the patch-replay heuristic — squashing already-reviewed commits reshapes the diff under reviewers mid-review. Atomic history is the explicit signal of a ready PR. |
| **Independently-merged parent detected** | Rebase `--onto` (Stage 3b) | Stacked branch carries parent commits that merged separately into base → skip duplicated prefix to avoid add/add conflicts. |
| **User asked for linear history** | Rebase | Explicit opt-in only — never the default. |

Before selecting patch-replay on `$AHEAD ≥ 5`, check PR draft state:

```bash
IS_DRAFT=$(gh pr view --json isDraft --jq .isDraft)
```

If `isDraft = false`, use merge instead and emit a one-line note: "Overriding
patch-replay heuristic — PR is ready-for-review, preserving atomic commit history."

Threshold is heuristic; user can override at run time. Auto mode picks without prompting.
