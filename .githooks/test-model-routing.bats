#!/usr/bin/env bats
# Behavioral tests for check-model-routing.sh.
# Run: bats .githooks/test-model-routing.bats

setup() {
  HOOK="${BATS_TEST_DIRNAME}/check-model-routing.sh"
  REPO="$BATS_TEST_TMPDIR/repo"

  mkdir -p "$REPO"
  git -C "$REPO" init -q
  git -C "$REPO" config user.email test@example.com
  git -C "$REPO" config user.name "Model Routing Test"
}

write_skill() {
  local skill_name="$1"
  local claude_tier="$2"
  local effort_level="$3"
  local openai_model="$4"
  local claude_model="${5:-}"
  local skill_dir="$REPO/skills/$skill_name"

  mkdir -p "$skill_dir"
  {
    printf '%s\n' '---'
    printf 'name: %s\n' "$skill_name"
    printf 'description: Test fixture for model routing\n'
    printf 'model: %s\n' "$claude_tier"
    printf 'effort: %s\n' "$effort_level"
    printf '%s\n' 'metadata:'
    printf '%s\n' '  model:'
    printf '    openai: %s\n' "$openai_model"
    if [[ -n "$claude_model" ]]; then
      printf '    claude: %s\n' "$claude_model"
    fi
    printf '%s\n' '---'
    printf '%s\n' '# Fixture'
  } > "$skill_dir/SKILL.md"
}

stage_skills() {
  git -C "$REPO" add skills
}

run_hook() {
  run bash -c 'cd "$1" && "$2"' _ "$REPO" "$HOOK"
}

assert_status() {
  [[ "$status" -eq "$1" ]] || {
    echo "expected status $1, got $status" >&2
    return 1
  }
}

assert_contains() {
  [[ "$output" == *"$1"* ]] || {
    echo "expected output to contain '$1', got: $output" >&2
    return 1
  }
}

@test "accepts the Claude-safe three-tier OpenAI mapping" {
  write_skill "test-haiku" "haiku" "low" "gpt-5.6-luna"
  write_skill "test-sonnet" "sonnet" "medium" "gpt-5.6-terra" "claude-sonnet-4-6"
  write_skill "test-opus" "opus" "xhigh" "gpt-5.6-sol" "claude-opus-4-8"
  stage_skills

  run_hook

  assert_status 0 || return 1
  [[ -z "$output" ]] || return 1
}

@test "rejects a missing top-level Claude model and effort" {
  write_skill "test-missing" "" "" "gpt-5.6-terra"
  stage_skills

  run_hook

  assert_status 1 || return 1
  assert_contains "top-level model must be haiku, sonnet, or opus" || return 1
}

@test "rejects an OpenAI model that does not match the Claude tier" {
  write_skill "test-wrong-openai" "opus" "high" "gpt-5.6-terra"
  stage_skills

  run_hook

  assert_status 1 || return 1
  assert_contains "model opus requires metadata.model.openai: gpt-5.6-sol" || return 1
}

@test "rejects contradictory optional Claude metadata" {
  write_skill "test-wrong-claude" "haiku" "low" "gpt-5.6-luna" "claude-sonnet-4-6"
  stage_skills

  run_hook

  assert_status 1 || return 1
  assert_contains "contradicts top-level model 'haiku'" || return 1
}

@test "judges the staged blob instead of an unstaged working-tree edit" {
  write_skill "test-staged" "sonnet" "medium" "gpt-5.6-terra"
  stage_skills
  write_skill "test-staged" "sonnet" "medium" "gpt-5.6-sol"

  run_hook

  assert_status 0 || return 1
  [[ -z "$output" ]] || return 1
}
