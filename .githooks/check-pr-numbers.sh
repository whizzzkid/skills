#!/usr/bin/env bash
# check-pr-numbers.sh — block committing internal PR / issue / run numbers in
# markdown. Real PR numbers identify internal work and must be genericized to a
# placeholder (`#NNN`, `repo#NNN`, `pulls/{n}`) before entering history.
#
# SCOPE: added lines of staged *.md files. Path forms (pulls/NN, issues/NN,
# runs/NN) are blocked everywhere; bare `#NN` / `PR #NN` are blocked only
# outside fenced code blocks (so CSS hex colours like `#39ff14`/`#222` in
# ```css fences pass). Exempts .githooks/* and the hooks' own docs.
#
# Written for bash 3.2 (macOS system bash) — no mapfile.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

files=$(git diff --cached --name-only --diff-filter=ACM -- '*.md' \
  | grep -vE '^\.githooks/' || true)
[[ -z "$files" ]] && exit 0

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  [[ -f "$f" ]] || continue
  in_fence=0
  while IFS= read -r line; do
    text="${line#+}"
    case "$text" in
      '```'*) in_fence=$(( 1 - in_fence )); continue ;;
    esac
    # Path forms — block anywhere (never a CSS colour).
    if printf '%s' "$text" | grep -qE '\b(pulls?|issues|runs)/[0-9]+'; then
      violations+=("  $f: $(printf '%s' "$text" | grep -oE '\b(pulls?|issues|runs)/[0-9]+' | head -1)  — in: ${text#"${text%%[![:space:]]*}"}")
      continue
    fi
    # Bare #NN / PR #NN — only outside fenced code (CSS hex lives in fences).
    [[ "$in_fence" -eq 1 ]] && continue
    if printf '%s' "$text" | grep -qE '#[0-9]{2,}([^0-9a-fA-F]|$)'; then
      violations+=("  $f: $(printf '%s' "$text" | grep -oE '#[0-9]{2,}' | head -1)  — in: ${text#"${text%%[![:space:]]*}"}")
    fi
  done < <(git diff --cached -U0 --diff-filter=ACM -- "$f" | grep -E '^\+' | grep -vE '^\+\+\+')
done <<< "$files"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: internal PR / issue number in added markdown" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "Genericize the number before committing:" >&2
  echo "  a bare PR number -> #NNN ; repo#<n> -> repo#NNN ; pulls/<n> -> pulls/{n}." >&2
  echo "A real CSS hex colour belongs inside a fenced code block (then it passes)." >&2
  exit 1
fi

exit 0
