#!/usr/bin/env bash
# check-prohibited.sh — block prohibited terms from entering the public repo,
# in BOTH staged file content and the commit message.
#
# Patterns are read from the gitignored `.skillprohibit` file (one `grep -iE`
# pattern per line; `#` comments and blank lines ignored). No prohibited term is
# embedded in this hook or anywhere committed — the term list stays machine-local.
#
# Modes (dispatched by lefthook):
#   pre-commit  (no arg)        → scan staged ADDED diff lines.
#   commit-msg  (arg = msgfile) → scan the commit message body.
#
# Copy `.skillprohibit.example` → `.skillprohibit` and add your terms to enable.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
PROHIBIT="$REPO_ROOT/.skillprohibit"

if [[ ! -f "$PROHIBIT" ]]; then
  echo "ℹ check-prohibited: no .skillprohibit file — skipping (copy .skillprohibit.example)" >&2
  exit 0
fi

PAT="$(mktemp)"
trap 'rm -f "$PAT"' EXIT
grep -vE '^[[:space:]]*(#|$)' "$PROHIBIT" > "$PAT" || true
[[ -s "$PAT" ]] || exit 0

msg_file="${1:-}"
if [[ -n "$msg_file" && -f "$msg_file" ]]; then
  scope="commit message"
  content="$(grep -vE '^[[:space:]]*#' "$msg_file" || true)"
else
  scope="staged diff"
  content="$(git diff --cached --unified=0 --no-color | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
fi

violations="$(printf '%s\n' "$content" | grep -inE -f "$PAT" || true)"

if [[ -n "$violations" ]]; then
  echo "✗ pre-commit: prohibited term in $scope" >&2
  echo "" >&2
  printf '%s\n' "$violations" | head -20 | sed 's/^/  /' >&2
  echo "" >&2
  echo "These terms (.skillprohibit) must never enter this public repo — not in" >&2
  echo "files and not in commit messages. Replace with a generic placeholder and" >&2
  echo "describe changes by category, never by naming the token." >&2
  exit 1
fi
exit 0
