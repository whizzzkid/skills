#!/usr/bin/env bash
# check-mermaid-links.sh — validate Mermaid `click` directives in navigable docs.
#
# GitHub renders Mermaid in a sandboxed iframe, so a `click ... href` with a
# RELATIVE path (./foo, ../foo) or a bare in-page anchor (#foo) resolves against
# the iframe origin, not the repo — it 404s. Only absolute URLs navigate. lychee
# (check-links.sh) cannot see these — they live inside ```mermaid code fences,
# which link parsers skip — so this hook covers them.
#
# Enforced on every `click <id> href "<target>"` in a README / top-level *.md /
# docs/ file:
#   - RELATIVE (./, ../) or bare-anchor (#) target            -> BLOCK (404s on GitHub)
#   - canonical repo blob URL whose file does not exist       -> BLOCK (broken target)
#   - other absolute https URL                                -> allowed (external, not checked offline)
#
# Runs only when a navigable doc is staged, but scans the whole navigable surface
# so a skill rename that orphans a diagram link in an untouched doc is caught.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

BLOB_PREFIX="https://github.com/whizzzkid/skills/blob/main/"

staged=$(git diff --cached --name-only --diff-filter=ACMR \
  | grep -E '(^|/)README\.md$|^docs/.*\.md$|^[^/]+\.md$' || true)
[[ -z "$staged" ]] && exit 0

# Navigable docs to scan (mirror check-links.sh scope; skip the scaffold).
# `|| true`: grep exits 1 when nothing matches, which under `set -o pipefail`
# would abort the hook instead of yielding an empty (harmless) doc set.
docs=$(find . \
  \( -name 'README.md' -o -path './docs/*' -o -path './*.md' \) \
  -not -path '*/_template/*' -not -path '*/node_modules/*' 2>/dev/null \
  | grep -E '(^|/)README\.md$|^\./docs/.*\.md$|^\./[^/]+\.md$' | sort -u || true)

relative=()
broken=()

while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  # Extract every click directive's href target with its line number.
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    lineno="${hit%%:*}"
    target="${hit#*:}"
    case "$target" in
      ./*|../*|"#"*)
        relative+=("  $file:$lineno  →  $target") ;;
      "$BLOB_PREFIX"*)
        rel="${target#"$BLOB_PREFIX"}"
        rel="${rel%%#*}"            # strip any #anchor
        [[ -f "$rel" ]] || broken+=("  $file:$lineno  →  $target") ;;
      https://*)
        : ;;                        # external absolute URL — not validated offline
      *)
        relative+=("  $file:$lineno  →  $target (unrecognized; use an absolute https URL)") ;;
    esac
  # Match both click forms — `click ID href "url"` and the shorthand
  # `click ID "url"` (Mermaid accepts both) — anchored at line start so prose
  # mentioning "click" is never matched. Extract the FIRST quoted string (the
  # link target; a trailing "tooltip" is ignored).
  done < <(grep -nE '^[[:space:]]*click[[:space:]]+[^"]*"' "$file" \
            | sed -E 's/^([0-9]+):[[:space:]]*click[[:space:]]+[^"]*"([^"]*)".*/\1:\2/')
done <<< "$docs"

if [[ ${#relative[@]} -gt 0 || ${#broken[@]} -gt 0 ]]; then
  echo "✗ pre-commit: invalid Mermaid click directive(s)" >&2
  echo "" >&2
  if [[ ${#relative[@]} -gt 0 ]]; then
    echo "Relative / anchor click targets — these 404 on GitHub's sandboxed mermaid" >&2
    echo "iframe. Use an absolute URL (${BLOB_PREFIX}<path>):" >&2
    printf '%s\n' "${relative[@]}" >&2
    echo "" >&2
  fi
  if [[ ${#broken[@]} -gt 0 ]]; then
    echo "Canonical blob URL targets that do not resolve to a repo file:" >&2
    printf '%s\n' "${broken[@]}" >&2
    echo "" >&2
  fi
  exit 1
fi

exit 0
