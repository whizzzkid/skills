# Base-Detection Algorithm

Detect the branch's actual fork point before measuring scope. Assuming the
default branch is the base → PR with unrelated commits in the diff (from a
parent in-flight branch), CI failures against the wrong target, and a silent
stacked-PR lacking the `[<feature>-part-N/M]` annotation.

## Algorithm

Compute merge-base distance between the current branch and every candidate base
— the default branch plus every open PR's `headRefName` (yours and others'). The
candidate with the **closest** merge-base (smallest commit distance) is the real
base; ties prefer the default branch.

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
                 | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

# Candidate set: default + every open PR's head ref
CANDIDATES=$(
  { echo "$DEFAULT_BRANCH"
    gh pr list --state open --json headRefName --jq '.[].headRefName'
  } | sort -u
)

BEST_BASE="$DEFAULT_BRANCH"
BEST_DIST=999999
HEAD_SHA=$(git rev-parse HEAD)
while IFS= read -r CAND; do
  # Resolve to origin/<cand>, else the local ref; a fetch failure must not drop a local-only candidate.
  REF="origin/$CAND"
  git rev-parse --verify --quiet "$REF" >/dev/null 2>&1 \
    || git fetch origin "$CAND" --quiet 2>/dev/null \
    || REF="$CAND"
  MB=$(git merge-base "$HEAD_SHA" "$REF" 2>/dev/null) || continue
  [ "$MB" = "$HEAD_SHA" ] && continue   # candidate is downstream of HEAD; not a base
  DIST=$(git rev-list --count "$MB..$HEAD_SHA")
  if [ "$DIST" -lt "$BEST_DIST" ] || \
     { [ "$DIST" -eq "$BEST_DIST" ] && [ "$CAND" = "$DEFAULT_BRANCH" ]; }; then
    BEST_DIST=$DIST
    BEST_BASE=$CAND
  fi
done <<< "$CANDIDATES"
```

## Failure handling

- **`$BEST_DIST` unchanged (`999999`) after the loop = detection FAILURE, not
  "base = default"** — no merge-base resolved. Check iteration form first
  (unquoted `for` in zsh does not word-split → read-loop required;
  `wk-workstyle-shell` owns the rule); then retry against
  `origin/$DEFAULT_BRANCH` after a fresh fetch.

## Non-default base prompt

If `$BEST_BASE` differs from `$DEFAULT_BRANCH`, surface to the user:

> "This branch was forked from `{BEST_BASE}` (open PR #{N}), not
> `{DEFAULT_BRANCH}`. Choose:
>
> **A)** Create this PR with `--base {BEST_BASE}` and treat it as stacked (adds
> `[<feature>-part-N/M]` and `## Stack` to the body).
> **B)** Rebase onto `{DEFAULT_BRANCH}` first, then create against the default
> base.
> **C)** Cancel.
>
> Reply `A` / `B` / `C`."

- Auto mode picks **A** — preserving the existing fork point is non-destructive.
- **B** invokes `wk-pr-update` to rebase before proceeding.

## Related references

- **Draft-base override:** [`draft-base-override.md`](draft-base-override.md).
- **Merged-base check:** [`merged-base-check.md`](merged-base-check.md).
