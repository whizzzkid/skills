#!/usr/bin/env bash
# check-relative-paths.sh — forbid machine-absolute / home-rooted paths in
# committed content. Paths in this repo must be relative to the repo or use a
# portable placeholder; machine-absolute paths leak usernames into history.
#
# SCOPE: scans only ADDED lines of the staged diff (never pre-existing content),
# so it blocks new leaks without forcing a sweep of historical references.
#
# BLOCKED in an added line:
#   /Users/<...>     /home/<...>     /root/<...>     bare ~/<...>
#
# ALLOWED (portable, no machine identity):
#   $HOME  ${HOME}  $WK_SKILLS_HOME  ${WK_SKILLS_HOME}  $CLAUDE_PROJECT_DIR
#   any other $VAR / ${VAR} env-var-rooted path
#
# EXEMPT files: .githooks/* (these hooks and their docs define the patterns
# literally) and lockfiles.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Collect staged, added/changed text files, excluding the hooks dir itself.
# (No mapfile — must run under bash 3.2, the macOS system bash.)
files=$(git diff --cached --name-only --diff-filter=ACM \
  | grep -vE '^\.githooks/' \
  | grep -vE '\.(lock|sum|png|jpg|jpeg|gif|pdf|ico|woff2?)$' || true)

[[ -z "$files" ]] && exit 0

violations=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  [[ -f "$f" ]] || continue
  # Added lines only (strip the leading '+', skip the +++ header).
  while IFS= read -r line; do
    text="${line#+}"
    # Strip env-var path roots so they are not mistaken for bare paths.
    probe="${text//\$\{HOME\}/}"
    probe="${probe//\$HOME/}"
    probe="${probe//\$\{WK_SKILLS_HOME\}/}"
    probe="${probe//\$WK_SKILLS_HOME/}"
    probe="${probe//\$CLAUDE_PROJECT_DIR/}"
    if printf '%s' "$probe" | grep -qE '(^|[^[:alnum:]_./~])(/Users/|/home/|/root/)' \
       || printf '%s' "$probe" | grep -qE '(^|[^[:alnum:]_$])~/'; then
      violations+=("  $f: ${text#"${text%%[![:space:]]*}"}")
    fi
  done < <(git diff --cached -U0 --diff-filter=ACM -- "$f" \
            | grep -E '^\+' | grep -vE '^\+\+\+')
done <<< "$files"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: machine-absolute or home-rooted path in added content" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "Use a repo-relative path or a portable placeholder instead:" >&2
  echo "  \$HOME, \$WK_SKILLS_HOME, \$CLAUDE_PROJECT_DIR, or a path relative to the repo." >&2
  echo "Never commit /Users/<name>/, /home/<name>/, /root/, or bare ~/ paths." >&2
  exit 1
fi

exit 0
