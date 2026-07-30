#!/usr/bin/env bats
# Behavioral test for the Claude Code target used by scripts/install-skills.sh.
# Run: bats .githooks/test-install-skills.bats

setup() {
  TEST_REPO="$BATS_TEST_TMPDIR/repo"
  TEST_BIN="$BATS_TEST_TMPDIR/bin"
  TEST_HOME="$BATS_TEST_TMPDIR/home"
  INSTALL_ARGS="$BATS_TEST_TMPDIR/install-args"

  mkdir -p "$TEST_REPO/scripts" "$TEST_BIN" "$TEST_HOME/.claude/skills"
  cp "$BATS_TEST_DIRNAME/../scripts/install-skills.sh" "$TEST_REPO/scripts/"

  cat > "$TEST_REPO/scripts/register-hooks.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

  cat > "$TEST_BIN/npx" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$INSTALL_ARGS"
exit "${NPX_STATUS:-0}"
EOF

  chmod +x \
    "$TEST_REPO/scripts/install-skills.sh" \
    "$TEST_REPO/scripts/register-hooks.sh" \
    "$TEST_BIN/npx"
}

@test "installs every skill for Claude Code" {
  run env \
    HOME="$TEST_HOME" \
    INSTALL_ARGS="$INSTALL_ARGS" \
    PATH="$TEST_BIN:$PATH" \
    "$TEST_REPO/scripts/install-skills.sh"

  [[ "$status" -eq 0 ]] || return 1
  run grep -Fx -- "claude-code" "$INSTALL_ARGS"
  [[ "$status" -eq 0 ]] || return 1
}

@test "preserves active skills when the package runner is unavailable" {
  mkdir -p "$TEST_HOME/.claude/skills/wk-existing"
  touch "$TEST_HOME/.claude/skills/wk-existing/marker"
  rm "$TEST_BIN/npx"

  run env \
    HOME="$TEST_HOME" \
    PATH="$TEST_BIN:/usr/bin:/bin" \
    "$TEST_REPO/scripts/install-skills.sh"

  [[ "$status" -ne 0 ]] || return 1
  [[ -f "$TEST_HOME/.claude/skills/wk-existing/marker" ]]
}

@test "preserves active skills when replacement installation fails" {
  mkdir -p "$TEST_HOME/.claude/skills/wk-existing"
  touch "$TEST_HOME/.claude/skills/wk-existing/marker"

  run env \
    HOME="$TEST_HOME" \
    INSTALL_ARGS="$INSTALL_ARGS" \
    NPX_STATUS=1 \
    PATH="$TEST_BIN:$PATH" \
    "$TEST_REPO/scripts/install-skills.sh"

  [[ "$status" -ne 0 ]] || return 1
  [[ -f "$TEST_HOME/.claude/skills/wk-existing/marker" ]]
}

@test "preserves active skills when Python is unavailable" {
  mkdir -p "$TEST_HOME/.claude/skills/wk-existing"
  touch "$TEST_HOME/.claude/skills/wk-existing/marker"
  ln -s "$(command -v bash)" "$TEST_BIN/bash"
  ln -s "$(command -v dirname)" "$TEST_BIN/dirname"
  ln -s "$(command -v rm)" "$TEST_BIN/rm"

  run env \
    HOME="$TEST_HOME" \
    INSTALL_ARGS="$INSTALL_ARGS" \
    PATH="$TEST_BIN" \
    "$TEST_REPO/scripts/install-skills.sh"

  [[ "$status" -ne 0 ]] || return 1
  [[ -f "$TEST_HOME/.claude/skills/wk-existing/marker" ]]
}

@test "preserves active skills when the hook registrar is unavailable" {
  mkdir -p "$TEST_HOME/.claude/skills/wk-existing"
  touch "$TEST_HOME/.claude/skills/wk-existing/marker"
  chmod -x "$TEST_REPO/scripts/register-hooks.sh"

  run env \
    HOME="$TEST_HOME" \
    INSTALL_ARGS="$INSTALL_ARGS" \
    PATH="$TEST_BIN:$PATH" \
    "$TEST_REPO/scripts/install-skills.sh"

  [[ "$status" -ne 0 ]] || return 1
  [[ -f "$TEST_HOME/.claude/skills/wk-existing/marker" ]]
}

@test "removes only deprecated skills after replacement succeeds" {
  mkdir -p \
    "$TEST_REPO/skills/example" \
    "$TEST_HOME/.claude/skills/wk-existing" \
    "$TEST_HOME/.claude/skills/wk-retired"
  printf '%s\n' "name: wk-existing" > "$TEST_REPO/skills/example/SKILL.md"
  touch "$TEST_HOME/.claude/skills/wk-existing/marker"
  touch "$TEST_HOME/.claude/skills/wk-retired/marker"

  run env \
    HOME="$TEST_HOME" \
    INSTALL_ARGS="$INSTALL_ARGS" \
    PATH="$TEST_BIN:$PATH" \
    "$TEST_REPO/scripts/install-skills.sh"

  [[ "$status" -eq 0 ]] || return 1
  [[ -f "$TEST_HOME/.claude/skills/wk-existing/marker" ]]
  [[ ! -e "$TEST_HOME/.claude/skills/wk-retired" ]]
}
