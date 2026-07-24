#!/usr/bin/env bats
# Tests for the scope-guard PreToolUse hook.
# Run: bats skills/scope-guard/tests/scope-guard.bats

setup() {
  HOOK="${BATS_TEST_DIRNAME}/../hooks/scope-guard.sh"
  REPO="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
}

# Emit a PreToolUse payload: $1=tool_name $2=command-or-filepath $3=key(command|file_path)
payload() {
  python3 -c '
import json, sys
tool, val, key, cwd = sys.argv[1:5]
print(json.dumps({"tool_name": tool, "tool_input": {key: val}, "cwd": cwd}))
' "$1" "$2" "$3" "$REPO"
}

run_bash()  { run bash -c "echo '$(payload Bash "$1" command)' | '$HOOK'"; }
run_edit()  { run bash -c "echo '$(payload Edit "$1" file_path)' | '$HOOK'"; }

# -- Bash: block searches rooted outside the repo ----------------------------
@test "blocks find /" {
  run_bash "find / -name foo"
  [ "$status" -eq 2 ]
}

@test "blocks find /usr/local" {
  run_bash "find /usr/local -name foo"
  [ "$status" -eq 2 ]
}

@test "blocks grep -r at filesystem root" {
  run_bash "grep -rn foo /"
  [ "$status" -eq 2 ]
}

@test "blocks rg against an out-of-repo absolute path" {
  run_bash "rg foo /etc"
  [ "$status" -eq 2 ]
}

@test "blocks a quoted out-of-repo search root" {
  run_bash 'find "/etc" -name x'
  [ "$status" -eq 2 ]
}

@test "blocks grep --recursive (long flag) at an out-of-repo path" {
  run_bash "grep --recursive foo /etc"
  [ "$status" -eq 2 ]
}

@test "blocks find / even with a glob pattern argument" {
  run_bash "find / -name '*.txt'"
  [ "$status" -eq 2 ]
}

@test "normalizes .. and blocks an escape via repo-relative traversal" {
  run_bash "find $REPO/../../etc -name x"
  [ "$status" -eq 2 ]
}

# -- Bash: allow in-scope searches (false-positive guards) -------------------
@test "allows find with an absolute path INSIDE the repo" {
  run_bash "find $REPO/skills -name SKILL.md"
  [ "$status" -eq 0 ]
}

@test "allows find with a relative path" {
  run_bash "find . -name foo"
  [ "$status" -eq 0 ]
}

@test "allows grep -r with a relative path" {
  run_bash "grep -rn foo skills/"
  [ "$status" -eq 0 ]
}

@test "allows rg with no path (defaults to cwd)" {
  run_bash "rg foo"
  [ "$status" -eq 0 ]
}

@test "allows a non-search command touching an absolute system path" {
  run_bash "cat /etc/hosts"
  [ "$status" -eq 0 ]
}

@test "allows an ordinary git command" {
  run_bash "git log --oneline"
  [ "$status" -eq 0 ]
}

@test "allows an in-repo root glued to a trailing semicolon by a cd prefix" {
  run_bash "cd $REPO; grep -rn foo skills/"
  [ "$status" -eq 0 ]
}

@test "still blocks an out-of-repo root glued to a trailing semicolon" {
  run_bash "cd /etc; find /etc -name x"
  [ "$status" -eq 2 ]
}

# -- Edit/Write: warn (never block) outside the repo -------------------------
@test "Edit outside the repo warns but does not block" {
  run_edit "$HOME/.claude/settings.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
}

@test "Edit inside the repo is silent" {
  run_edit "$REPO/skills/x.md"
  [ "$status" -eq 0 ]
  [[ "$output" != *"WARNING"* ]]
}

# -- Escape hatch + non-git safety -------------------------------------------
@test "SCOPE_GUARD_OFF=1 bypasses the block" {
  run bash -c "echo '$(payload Bash "find / -name x" command)' | SCOPE_GUARD_OFF=1 '$HOOK'"
  [ "$status" -eq 0 ]
}

@test "allows when cwd is not a git repo (cannot reason about scope)" {
  run bash -c "printf '%s' '{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"find / -name x\"},\"cwd\":\"/tmp\"}' | '$HOOK'"
  [ "$status" -eq 0 ]
}
