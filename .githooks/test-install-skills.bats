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
