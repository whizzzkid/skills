#!/usr/bin/env bash
# check-skill-links.sh — enforce CLAUDE.md Rule 3:
#   inline mentions of wk-* skills in staged markdown files must use
#   relative markdown links, not bare backtick references.
#
# Allowed forms (must be linked):
#   [`wk-foo`](../foo/README.md)
#   [`wk-foo`](./foo/README.md)
#   [`wk-foo`](path/to/foo/README.md)
#
# Blocked forms (bare backtick, no link):
#   `wk-foo`     (not immediately preceded or followed by a link bracket)
#
# Exceptions — these are never flagged:
#   - Fenced code blocks (``` ... ```)
#   - HTML comments (<!-- ... -->)
#   - YAML frontmatter (--- ... ---)
#   - Mermaid click directives (they use their own syntax)
#   - Lines in the SKILL.md `name:` frontmatter field
#   - The SKILL.md `description:` field value
#   - Lines matching `- wk-foo:` (skill list entries in system prompts)
#   - Lines matching `wk-foo:` at start (YAML key form in allowed-tools)

set -euo pipefail

# Collect staged *.md files (excluding .learned.md)
staged_md=$(git diff --cached --name-only --diff-filter=ACMR \
  | perl -ne 'print if m{\.md$} && !m{\.learned\.md$}')

[[ -z "$staged_md" ]] && exit 0

violations=()

while IFS= read -r file; do
  [[ -f "$file" ]] || continue

  # Use perl to skip fenced code blocks, YAML frontmatter, HTML comments,
  # and find bare `wk-*` that are NOT inside a markdown link [...](...)
  hits=$(perl -ne '
    BEGIN {
      $in_fence = 0;
      $in_front = 0;
      $front_count = 0;
      $lineno = 0;
    }
    $lineno++;

    # Frontmatter: first --- block only
    if ($lineno == 1 && /^---\s*$/) { $in_front = 1; next; }
    if ($in_front && /^---\s*$/) { $in_front = 0; next; }
    next if $in_front;

    # Fenced code blocks
    if (/^```/) { $in_fence = !$in_fence; next; }
    next if $in_fence;

    # HTML comment lines (single-line)
    next if /<!--.*-->/;
    next if /^<!--/;

    # Mermaid click directives
    next if /^\s*click\s+\w/;

    # Skill-list entry lines: "- wk-foo: ..." or "wk-foo:" at column 0
    next if /^\s*-\s+wk-[\w-]+:/;
    next if /^wk-[\w-]+:/;

    # Match bare `wk-*` that are NOT immediately inside [...](...)
    # A linked form looks like: [`wk-foo`](
    # We want backtick-wk-*-backtick NOT preceded by [ on the same line
    while (/(?<!\[)`(wk-[\w-]+)`(?!\])/g) {
      my $skill = $1;
      print "$ARGV:$lineno:$skill\n";
    }
  ' "$file" 2>/dev/null || true)

  while IFS= read -r hit; do
    [[ -n "$hit" ]] && violations+=("  $hit")
  done <<< "$hits"

done <<< "$staged_md"

if [[ ${#violations[@]} -gt 0 ]]; then
  echo "✗ pre-commit: bare \`wk-*\` reference — must be a relative markdown link" >&2
  echo "" >&2
  for v in "${violations[@]}"; do
    echo "$v" >&2
  done
  echo "" >&2
  echo "Fix: replace \`wk-foo\` with [\`wk-foo\`](../foo/README.md)" >&2
  echo "(use ../<name>/README.md from sibling skill READMEs," >&2
  echo "     ./<name>/README.md from skills/README.md)" >&2
  exit 1
fi

exit 0
