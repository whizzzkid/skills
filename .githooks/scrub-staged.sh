#!/usr/bin/env bash
# scrub-staged.sh — block commits whose staged diff leaks employer/org
# identifiers or internal URLs. Invoked by lefthook pre-commit.
#
# Patterns:
#   - Resolved value of $EMPLOYER and $GITHUB_ORG env vars (case-insensitive).
#   - Every regex in .githooks/scrub-denylist.txt (one per line, # comments).
#
# Allowed (never matched):
#   - Literal env-var references: $EMPLOYER, ${EMPLOYER}, $GITHUB_ORG, ${GITHUB_ORG}.
#   - The denylist file itself.
#
# Uses perl for both diff parsing and PCRE matching — macOS BSD grep lacks -P.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
DENYLIST="$REPO_ROOT/.githooks/scrub-denylist.txt"

# Build pattern list from env + denylist file.
patterns=()

if [[ -n "${EMPLOYER:-}" ]]; then
  patterns+=("(?i)${EMPLOYER}")
fi
if [[ -n "${GITHUB_ORG:-}" ]]; then
  patterns+=("(?i)${GITHUB_ORG}")
fi

if [[ -f "$DENYLIST" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    patterns+=("$line")
  done < "$DENYLIST"
fi

if [[ ${#patterns[@]} -eq 0 ]]; then
  exit 0
fi

# Collect staged files (excluding the denylist file itself).
staged_files=$(git diff --cached --name-only --diff-filter=ACMR \
  | perl -ne 'print unless m{^\.githooks/scrub-denylist\.txt$}' || true)
[[ -z "$staged_files" ]] && exit 0

# Export patterns and allowlist regex for perl.
SCRUB_PATTERNS=$(printf '%s\n' "${patterns[@]}")
export SCRUB_PATTERNS
export SCRUB_ALLOW='\$\{?(?:EMPLOYER|GITHUB_ORG)\}?'

violations=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  export SCRUB_FILE="$file"
  hits=$(git diff --cached -U0 -- "$file" | perl -ne '
    BEGIN {
      $f = $ENV{SCRUB_FILE};
      @pats = grep { length } split /\n/, $ENV{SCRUB_PATTERNS};
      $allow = $ENV{SCRUB_ALLOW};
      $ln = 0;
    }
    if (/^\@\@ .*?\+(\d+)/) { $ln = $1; next; }
    next if /^\+\+\+/;
    if (/^\+(.*)/) {
      my $content = $1;
      my $stripped = $content;
      $stripped =~ s/$allow//g;
      for my $p (@pats) {
        if ($stripped =~ /$p/) {
          printf "%s:%d:%s  [matched: %s]\n", $f, $ln, $content, $p;
          last;
        }
      }
      $ln++;
    }
  ' || true)
  [[ -n "$hits" ]] && violations+="${hits}"$'\n'
done <<< "$staged_files"

violations="${violations%$'\n'}"

if [[ -n "$violations" ]]; then
  echo "✗ pre-commit: staged diff contains denylisted identifiers" >&2
  echo "" >&2
  while IFS= read -r line; do
    echo "  $line" >&2
  done <<< "$violations"
  echo "" >&2
  echo "Fix: replace identifiers with placeholders (\$EMPLOYER, \$GITHUB_ORG, {owner}/{repo})," >&2
  echo "remove internal URLs/threads, then re-stage and commit." >&2
  echo "" >&2
  echo "Add additional repo-local patterns at .githooks/scrub-denylist.txt." >&2
  exit 1
fi

exit 0
