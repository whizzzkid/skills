---
class: principle
---

**Rule** — For a stack of dependent PRs, prefer the `gh stack` extension
(`github/gh-stack`, official, Go, gh v2.0+) over hand-chaining `--base`. The
extension owns branch creation, base chaining, cascading rebase, and linked-PR
submission. Fall back to the manual convention only when it is unavailable.

**Where** — wk-pr "Stacking multiple PRs" subsection.

## Availability probe (run once)

`gh stack` is in private preview and only works when the repo is enabled for it.
Probe before delegating; any non-zero exit → manual fallback:

```bash
gh extension list | grep -q 'github/gh-stack' \
  && gh stack view >/dev/null 2>&1 \
  && echo "gh-stack ready" || echo "manual fallback"
```

- Install if missing (do not assume): `gh extension install github/gh-stack`.
- Metadata lives in `.git/gh-stack` (local, uncommitted). Exit codes: 0 ok,
  3 rebase conflict, 4 GitHub API failure, 8 stack locked by another process.

## Delegated lifecycle (gh-stack available)

- `gh stack init -b <trunk> [branches...]` — start/adopt a stack rooted at trunk.
- `gh stack add -m "<msg>" [branch]` — add a branch on top (run on topmost).
- `gh stack submit` — push every branch AND open one PR per branch, linked as a
  Stack on GitHub with each base set to the branch below (`--auto` to skip the
  editor). This replaces per-PR `gh pr create --base`.
- `gh stack sync --prune` — fetch, cascade-rebase, push, re-link PRs, prune. Use
  after a base moves or a mid-stack PR merges.
- `gh stack rebase` — cascading rebase from trunk up (switches to `--onto` for
  merged PRs); `--continue` / `--abort` on conflict.
- `gh stack view` — inspect branches, ordering, PR links.
- Let the extension set PR bases and `[Part X/Y]`-equivalent linkage — do not
  also hand-edit `--base` or inject a manual `## Stack` section.

## Manual fallback (extension absent or repo not in preview)

- Append `[Part X/Y]` at the end of the PR title (e.g.
  `feat(auth): ✨ add OAuth2 login [Part 1/3]`).
- Base each PR on the previous one: `--base previous-branch`.
- Each PR must pass CI in isolation — no forward dependencies.
- Inject a `## Stack` section listing all parts with PR numbers and status:

```bash
gh pr create --draft --base previous-branch \
  --title "feat(scope): ✨ description [Part X/Y]" \
  --body "$(cat <<'EOF'
## Summary
- What changed and why

## Stack
- Part 1: #PR_NUMBER (merged/open)
- **Part 2: this PR**
- Part 3: pending

## Test plan
- [ ] How to verify the changes

EOF
)"
```

- Repo template found → use the template as the body structure and inject the
  same `## Stack` section into it.
