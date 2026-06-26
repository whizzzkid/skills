#!/usr/bin/env bash
# check-links.sh — validate links in navigable docs with lychee (offline).
#
# Catches broken relative links and dead anchors in README files, top-level
# markdown, and docs/. Online links are skipped (see lychee.toml) — external-URL
# liveness belongs in a networked CI pass, not a fast deterministic pre-commit.
#
# SCOPE: the navigable doc surface only —
#   README.md (any level), top-level *.md, docs/**.md
# SKILL.md, references/*.md, learnings/, retrospect/, and _template/ are OUT of
# scope: they are runtime-instruction or archive files dense with illustrative /
# template link-shaped text that is not meant to resolve (mirrors the scoping of
# check-skill-links.sh).
#
# Runs only when a navigable doc is staged, but validates the WHOLE navigable
# surface (not just staged files) so a rename that orphans a link in an untouched
# doc is still caught.
#
# Mermaid `click` targets are NOT validated here — lychee does not parse fenced
# code blocks. check-mermaid-links.sh covers them.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Trigger only when a navigable doc is staged.
staged=$(git diff --cached --name-only --diff-filter=ACMR \
  | grep -E '(^|/)README\.md$|^docs/.*\.md$|^[^/]+\.md$' || true)
[[ -z "$staged" ]] && exit 0

if ! command -v mise >/dev/null 2>&1; then
  echo "✗ pre-commit: mise not found — cannot run lychee link check." >&2
  echo "  Install mise and run 'mise install' (lychee is pinned in .mise.toml)." >&2
  exit 1
fi

# lychee auto-loads ./lychee.toml. Add the dynamic repo-root remap so absolute
# canonical GitHub blob URLs validate offline against the local worktree.
if ! mise exec -- lychee \
    --remap "https://github.com/whizzzkid/skills/blob/main/(.*) file://$REPO_ROOT/\$1" \
    './README.md' './*.md' './skills/*.md' './skills/*/README.md' './docs/**/*.md'; then
  echo "" >&2
  echo "✗ pre-commit: lychee found broken link(s) in navigable docs (see above)." >&2
  echo "  Fix the path/anchor, or exclude an illustrative placeholder in lychee.toml." >&2
  exit 1
fi

exit 0
