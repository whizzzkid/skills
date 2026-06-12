#!/usr/bin/env bash
# check-usernames.sh — block committing a human @-mention (reviewer / teammate
# login) in prose. Usernames identify real people and must be anonymized to a
# placeholder (`{reviewer}`, `{user}`, `{author}`) before they enter history.
#
# SCOPE: added lines only, outside fenced code blocks (``` … ```), in text
# files. Exempts .githooks/* (this hook lists tokens literally) and lockfiles.
#
# A bare `@handle` is flagged UNLESS it is one of:
#   - a known generic placeholder / at-token (allowlist below)
#   - followed by `.` (file arg / email / `@attr.value`)
#   - followed by `/` (npm scope `@org/pkg`)
#   - preceded by an alphanumeric (email `user@host`, version `tool@v4`)
#   - a GitHub Actions version ref `@v<digits>`
#
# Written for bash 3.2 (macOS system bash) — no mapfile.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Allowlist of safe @-tokens (generic placeholders, CSS at-rules, decorators,
# jq/curl file args, repo conventions). Lowercase, no leading @.
ALLOW=" me reviewer reviewers user users author authors owner repo repos bot bots
  handle handles service project mention scope team your-team your-team-internal
  keyframes media import font-face supports charset namespace page apply layer tailwind
  property dataclass staticmethod classmethod abstractmethod param params returns raises
  override deprecated example file attr attribute payload monitor dashboard slo notebook
  pats sha pr_number code_review test "

files=$(git diff --cached --name-only --diff-filter=ACM \
  | grep -vE '^\.githooks/' \
  | grep -vE '\.(lock|sum|png|jpg|jpeg|gif|pdf|ico|woff2?)$' || true)
[[ -z "$files" ]] && exit 0

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  [[ -f "$f" ]] || continue
  in_fence=0
  while IFS= read -r line; do
    text="${line#+}"
    # Toggle fenced-code state on ``` lines; skip lines inside fences.
    case "$text" in
      '```'*) in_fence=$(( 1 - in_fence )); continue ;;
    esac
    [[ "$in_fence" -eq 1 ]] && continue
    # Extract candidate @handles: @ not preceded by an alnum, handle starts with a letter.
    for tok in $(printf '%s\n' "$text" | grep -oE '(^|[^A-Za-z0-9_])@[a-z][a-z0-9_-]+' 2>/dev/null | sed -E 's/^[^@]*@//'); do
      # Skip version refs @v<digits>
      printf '%s' "$tok" | grep -qE '^v[0-9]+$' && continue
      # Skip if allowlisted
      case "$ALLOW" in *" $tok "*) continue ;; esac
      # Skip if the original text shows @tok followed by . or / (file/email/scope)
      printf '%s' "$text" | grep -qE "@$tok[./]" && continue
      violations+=("  $f: @$tok  — in: ${text#"${text%%[![:space:]]*}"}")
    done
  done < <(git diff --cached -U0 --diff-filter=ACM -- "$f" | grep -E '^\+' | grep -vE '^\+\+\+')
done <<< "$files"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: human @-mention (username) in added content" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "Anonymize the username to a placeholder before committing:" >&2
  echo "  reviewer login → {reviewer}; teammate → {user}; PR author → {author}." >&2
  echo "If this is a genuine non-human at-token, add it to the ALLOW list in this hook." >&2
  exit 1
fi

exit 0
