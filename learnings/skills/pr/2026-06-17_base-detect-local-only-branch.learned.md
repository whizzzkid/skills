---
skill: wk-pr
date: 2026-06-17
type: gap
severity: medium
---

Base detection silently drops local-only branch candidates, leaving BEST_DIST at the sentinel and falling back to the default branch incorrectly.

**What happened:** The base-detection loop runs `git fetch origin "$CAND" || continue` for every candidate. When a branch exists locally (e.g. a worktree branch not yet pushed to origin), the fetch fails and `|| continue` silently skips that candidate. BEST_DIST never updates from 999999, so the algorithm falls back to the default branch even though the correct base is a local ref.

**Root cause:** The algorithm assumes every candidate must be fetched from origin before a merge-base can be computed. Local refs are already present and don't need a fetch — but the unconditional `|| continue` treats fetch failure as "candidate doesn't exist" rather than "candidate is already local."

**Suggested fix:** After the failed fetch, attempt the merge-base check directly against the local ref before skipping:

```bash
git fetch origin "$CAND" --quiet 2>/dev/null || {
  # Candidate may exist as a local-only ref — try without the remote prefix.
  MB=$(git merge-base "$HEAD_SHA" "$CAND" 2>/dev/null) || continue
  # fall through to distance calculation below
}
```

Alternatively, check whether `origin/$CAND` exists locally before fetching:

```bash
git rev-parse --verify "origin/$CAND" &>/dev/null || \
  git fetch origin "$CAND" --quiet 2>/dev/null || continue
```

Either approach prevents silent exclusion of valid local candidates (worktree branches, branches not yet pushed).
