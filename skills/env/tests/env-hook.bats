#!/usr/bin/env bats
# Tests for the wk-env PreToolUse hook (check-skill-env-vars.sh).
# Run: bats skills/env/tests/env-hook.bats
#
# Every assertion carries an explicit `|| return 1`. This suite's bats does not
# run test bodies under `errexit`, so a bare failing assertion that is not the
# final command in the body is silently inert — the test still reports ok. The
# `|| return 1` makes each assertion fatal on its own, independent of position.

setup() {
  HOOK="${BATS_TEST_DIRNAME}/../hooks/check-skill-env-vars.sh"

  # Hermetic fixture tree: HOME is redirected so the hook's `$HOME/.profile`
  # lookup reads a controlled file instead of the developer's real profile.
  FIX="$BATS_TEST_TMPDIR/fixture"
  export HOME="$FIX/home"
  mkdir -p "$HOME"
  : > "$HOME/.profile"

  mkdir -p "$FIX/skills"
  export WK_SKILLS_HOME="$FIX"

  # Guaranteed-absent in the process env; individual tests may plant it in .profile.
  unset WK_TEST_DECLARED_VAR
}

# Write a skill fixture: $1=dir-name, remaining args = declared env-vars (may be none).
make_skill() {
  local dir="$1"; shift
  mkdir -p "$FIX/skills/$dir"
  {
    echo '---'
    echo "name: $dir"
    if [ "$#" -gt 0 ]; then
      echo 'env-vars:'
      for v in "$@"; do echo "  - $v"; done
    else
      echo 'env-vars: []'
    fi
    echo '---'
    echo 'body'
  } > "$FIX/skills/$dir/SKILL.md"
}

# Pass the payload through the environment, never interpolated into the command
# string — a quote in the skill name would otherwise mangle the JSON.
run_hook() {
  PAYLOAD="$(python3 -c 'import json,sys; print(json.dumps({"tool_input":{"skill":sys.argv[1]}}))' "$1")"
  export PAYLOAD
  run bash -c 'printf %s "$PAYLOAD" | "$1"' _ "$HOOK"
}

assert_status()   { [ "$status" -eq "$1" ] || { echo "expected status $1, got $status" >&2; return 1; }; }
assert_silent()   { [ -z "$output" ]       || { echo "expected no output, got: $output" >&2; return 1; }; }
assert_contains() { [[ "$output" == *"$1"* ]] || { echo "expected output to contain '$1', got: $output" >&2; return 1; }; }
assert_lacks()    { [[ "$output" != *"$1"* ]] || { echo "expected output to omit '$1', got: $output" >&2; return 1; }; }

# -- Dir resolution: both naming conventions must resolve ---------------------
# The regression under test: a blind `${SKILL_NAME#wk-}` strip built a path that
# never existed for a prefix-retaining dir, so the hook exited 0 in silence and
# none of the declared vars were ever checked.
@test "resolves a dir that RETAINS the wk- prefix" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  run_hook "wk-fixture"
  assert_status 0 || return 1
  assert_contains "WK_TEST_DECLARED_VAR" || return 1
}

@test "resolves a dir that DROPS the wk- prefix" {
  make_skill "fixture" WK_TEST_DECLARED_VAR
  run_hook "wk-fixture"
  assert_status 0 || return 1
  assert_contains "WK_TEST_DECLARED_VAR" || return 1
}

@test "resolves a skill invoked by its bare (unprefixed) name" {
  make_skill "fixture" WK_TEST_DECLARED_VAR
  run_hook "fixture"
  assert_status 0 || return 1
  assert_contains "WK_TEST_DECLARED_VAR" || return 1
}

# Verbatim is tried first, so the exact display name wins over the stripped form.
@test "prefers the verbatim dir when both naming forms exist" {
  make_skill "wk-fixture" WK_VERBATIM_WINS
  make_skill "fixture"    WK_STRIPPED_WINS
  run_hook "wk-fixture"
  assert_contains "WK_VERBATIM_WINS" || return 1
  assert_lacks "WK_STRIPPED_WINS" || return 1
}

# -- The two silent exit-0 branches, kept distinguishable by behavior ---------
@test "stays silent for a skill that declares no env-vars" {
  make_skill "fixture"
  run_hook "wk-fixture"
  assert_status 0 || return 1
  assert_silent || return 1
}

# Plugin and third-party skills legitimately ship no dir in this repo, so an
# unresolvable name must not warn — otherwise the hook spams every invocation.
@test "stays silent for an unresolvable skill name" {
  run_hook "some-plugin:skill-that-has-no-dir"
  assert_status 0 || return 1
  assert_silent || return 1
}

@test "stays silent when WK_SKILLS_HOME is unset" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  unset WK_SKILLS_HOME
  run_hook "wk-fixture"
  assert_status 0 || return 1
  assert_silent || return 1
}

@test "stays silent when the payload carries no skill name" {
  run bash -c "printf '%s' '{\"tool_input\":{}}' | '$HOOK'"
  assert_status 0 || return 1
  assert_silent || return 1
}

# -- Var state classification ------------------------------------------------
@test "stays silent when every declared var is set and non-empty" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  export WK_TEST_DECLARED_VAR=present
  run_hook "wk-fixture"
  assert_status 0 || return 1
  assert_silent || return 1
}

@test "reports a declared var that is set but empty" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  export WK_TEST_DECLARED_VAR=""
  run_hook "wk-fixture"
  assert_contains "WK_TEST_DECLARED_VAR" || return 1
}

@test "reports still-missing when the var is absent from .profile too" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  run_hook "wk-fixture"
  assert_contains "Still missing" || return 1
  assert_contains "export WK_TEST_DECLARED_VAR=" || return 1
}

@test "reports resolved-after-sourcing when the var is only in .profile" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  echo 'export WK_TEST_DECLARED_VAR=from-profile' > "$HOME/.profile"
  run_hook "wk-fixture"
  assert_contains "Resolved after sourcing" || return 1
  assert_lacks "Still missing" || return 1
}

# Defends the indirect expansion and the `bash -c` lookup against a frontmatter
# entry that is not a valid shell identifier.
@test "skips a declared name that is not a valid shell identifier" {
  make_skill "wk-fixture" 'not-an-identifier'
  run_hook "wk-fixture"
  assert_status 0 || return 1
  assert_silent || return 1
}

# -- Never blocks ------------------------------------------------------------
# The hook is advisory: it warns on stderr but must never fail a skill call.
@test "exits 0 even when it emits a warning" {
  make_skill "wk-fixture" WK_TEST_DECLARED_VAR
  run_hook "wk-fixture"
  assert_status 0 || return 1
  [ -n "$output" ] || return 1
}
