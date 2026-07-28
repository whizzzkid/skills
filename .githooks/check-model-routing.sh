#!/usr/bin/env bash
# check-model-routing.sh — keep Claude-native tiers aligned with OpenAI model metadata.
#
# Claude Code owns the top-level `model` and `effort` fields. Provider-aware
# launchers may read `metadata.model.openai`; this hook keeps that custom
# annotation complete and consistent without replacing Claude's native values.
#
# Measures staged blobs so a partially-staged edit is judged exactly as committed.

set -euo pipefail

staged_skills=$(git diff --cached --name-only --diff-filter=ACMR \
  | { command grep -E '^skills/[^/]+/SKILL\.md$' || true; })

[[ -z "$staged_skills" ]] && exit 0

# Emits top-level model, effort, OpenAI override, and optional Claude override.
parse_routing() {
  git show ":$1" | awk '
    BEGIN {
      in_frontmatter = 0
      in_metadata = 0
      in_metadata_model = 0
      top_model = ""
      effort = ""
      openai_model = ""
      claude_model = ""
    }
    NR == 1 && $0 == "---" {
      in_frontmatter = 1
      next
    }
    in_frontmatter && $0 == "---" {
      print top_model "|" effort "|" openai_model "|" claude_model
      exit
    }
    !in_frontmatter {
      next
    }
    /^[A-Za-z_][A-Za-z0-9_-]*:/ {
      in_metadata = ($0 == "metadata:")
      in_metadata_model = 0
    }
    /^model:[[:space:]]*/ {
      top_model = $0
      sub(/^model:[[:space:]]*/, "", top_model)
      sub(/[[:space:]]*$/, "", top_model)
    }
    /^effort:[[:space:]]*/ {
      effort = $0
      sub(/^effort:[[:space:]]*/, "", effort)
      sub(/[[:space:]]*$/, "", effort)
    }
    in_metadata && /^  model:[[:space:]]*$/ {
      in_metadata_model = 1
      next
    }
    in_metadata && /^  [A-Za-z_][A-Za-z0-9_-]*:/ {
      in_metadata_model = 0
    }
    in_metadata_model && /^    openai:[[:space:]]*/ {
      openai_model = $0
      sub(/^    openai:[[:space:]]*/, "", openai_model)
      sub(/[[:space:]]*$/, "", openai_model)
    }
    in_metadata_model && /^    claude:[[:space:]]*/ {
      claude_model = $0
      sub(/^    claude:[[:space:]]*/, "", claude_model)
      sub(/[[:space:]]*$/, "", claude_model)
    }
  '
}

violations=()
while IFS= read -r skill_file; do
  [[ -z "$skill_file" ]] && continue

  routing=$(parse_routing "$skill_file")
  IFS='|' read -r top_model effort openai_model claude_model <<< "$routing"

  case "$top_model" in
    haiku) expected_openai="gpt-5.6-luna" ;;
    sonnet) expected_openai="gpt-5.6-terra" ;;
    opus) expected_openai="gpt-5.6-sol" ;;
    *)
      violations+=("  $skill_file: top-level model must be haiku, sonnet, or opus")
      continue
      ;;
  esac

  case "$effort" in
    low|medium|high|xhigh|max) ;;
    *) violations+=("  $skill_file: top-level effort must be low, medium, high, xhigh, or max") ;;
  esac

  if [[ "$openai_model" != "$expected_openai" ]]; then
    violations+=("  $skill_file: model $top_model requires metadata.model.openai: $expected_openai")
  fi

  if [[ -n "$claude_model" && "$claude_model" != *"$top_model"* ]]; then
    violations+=("  $skill_file: metadata.model.claude '$claude_model' contradicts top-level model '$top_model'")
  fi
done <<< "$staged_skills"

if (( ${#violations[@]} > 0 )); then
  echo "✗ pre-commit: skill model routing is incomplete or inconsistent" >&2
  echo "" >&2
  printf '%s\n' "${violations[@]}" >&2
  echo "" >&2
  echo "Keep Claude's top-level model/effort fields and align only the provider metadata:" >&2
  echo "  haiku → gpt-5.6-luna" >&2
  echo "  sonnet → gpt-5.6-terra" >&2
  echo "  opus → gpt-5.6-sol" >&2
  exit 1
fi

exit 0
