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

# Pass the payload through the environment, never interpolated into the command
# string — a single quote in the command under test would otherwise close the
# wrapping quote and silently mangle the JSON.
run_hook() { export PAYLOAD; run bash -c 'printf %s "$PAYLOAD" | "$1"' _ "$HOOK"; }

run_bash()  { PAYLOAD="$(payload Bash "$1" command)";   run_hook; }
run_edit()  { PAYLOAD="$(payload Edit "$1" file_path)"; run_hook; }

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

# Role classification must not relax a true positive: the SAME command whose
# pattern carries path shapes still blocks when a real out-of-repo root is also
# a path operand. Pairs with the allow case below — pattern vs path is the axis.
@test "still blocks an out-of-repo root when the pattern also carries path shapes" {
  run_bash "grep -rniE '/opt/vendor/x|widget' /etc"
  [ "$status" -eq 2 ]
}

@test "still blocks when -e supplies the pattern and the operand is a real root" {
  run_bash "grep -rn -e /opt/vendor/x /etc"
  [ "$status" -eq 2 ]
}

@test "still blocks an out-of-repo root in a later segment of a compound" {
  run_bash "rg -l widget skills/ && find /etc -name y"
  [ "$status" -eq 2 ]
}

@test "blocks ls -R with a value-less short flag cluster before the root" {
  run_bash "ls -Rt /etc"
  [ "$status" -eq 2 ]
}

# Pinned deliberately: per-segment role classification must NOT let this through.
# The search names only `.`, but a preceding cd moved the effective root outside
# the repo. A previous design note rejected per-segment attribution solely because
# it dropped this case; the cd target is charged against the following search so
# the false-positive relief costs no true positive.
@test "blocks a search whose effective root is moved outside by a preceding cd" {
  run_bash "cd /opt/vendor && grep -r needle ."
  [ "$status" -eq 2 ]
}

@test "allows a search after a cd that stays inside the repo" {
  run_bash "cd $REPO/skills && grep -r needle ."
  [ "$status" -eq 0 ]
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

@test "allows a bare / used as a word separator inside a quoted echo banner" {
  run_bash 'echo "=== a / b ==="; grep -rn token skills/'
  [ "$status" -eq 0 ]
}

@test "allows a bare / inside the search command's own quoted pattern" {
  run_bash "grep -rn 'a / b' skills/"
  [ "$status" -eq 0 ]
}

# A scrub check greps repo-relative files FOR absolute-path shapes: the shapes
# are the pattern operand, every path operand is relative. Charging the pattern
# as a search root false-blocks a fully in-scope command.
@test "allows abs path shapes in a recursive grep's pattern with relative operands" {
  run_bash "grep -rniE '/opt/vendor/x|/srv/data/y|widget' README.md AGENTS.md"
  [ "$status" -eq 0 ]
}

# Search-family detection is per-segment, not per-command-string: one search
# binary must not put an unrelated segment's arguments in scope.
@test "allows abs shapes in a non-recursive grep alongside a search in a compound" {
  run_bash "rg -l widget skills/ && grep -niE '/opt/vendor/x|widget' README.md"
  [ "$status" -eq 0 ]
}

@test "allows -f patternfile with relative operands (patterns never in argv)" {
  run_bash "grep -rEf patterns.txt README.md"
  [ "$status" -eq 0 ]
}

@test "still blocks an unbalanced-quote command (tokenizer falls back, fails closed)" {
  run_bash 'grep -rn "foo /etc'
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
  PAYLOAD="$(payload Bash "find / -name x" command)"
  export PAYLOAD
  run bash -c 'printf %s "$PAYLOAD" | SCOPE_GUARD_OFF=1 "$1"' _ "$HOOK"
  [ "$status" -eq 0 ]
}

# Matching is lexical and never shell-expands, so an out-of-repo root arriving as
# `$VAR/...` is not an absolute path and is never compared. Pinned deliberately: this
# by-design gap has twice been mis-reported as "the guard blocks recursive out-of-repo
# enumeration", and the paired block case below shows recursion is not the axis.
@test "does not judge an unexpanded \$VAR-rooted out-of-repo search root" {
  run_bash 'find "$HOME/.claude/skills/learnings" -type f'
  [ "$status" -eq 0 ]
}

# Differs from the case above ONLY in quote style: single quotes keep `$HOME` literal
# in the payload, double quotes expand it here so the hook receives the absolute path.
# Same logical destination, opposite verdicts — the spelling is what decides.
@test "blocks the same out-of-repo root once hand-expanded to a literal" {
  run_bash "find $HOME/.claude/skills/learnings -type f"
  [ "$status" -eq 2 ]
}

@test "allows when cwd is not a git repo (cannot reason about scope)" {
  run bash -c "printf '%s' '{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"find / -name x\"},\"cwd\":\"/tmp\"}' | '$HOOK'"
  [ "$status" -eq 0 ]
}

# -- symlinked repo prefix: physical root vs logical operand ------------------
# `git rev-parse --show-toplevel` reports the PHYSICAL root, while a path operand
# keeps whatever logical prefix the caller typed. On macOS /tmp, /var and /etc are
# symlinks, so a lexical compare judged an entirely in-repo search "outside" and
# false-blocked it — reported in the field as "scope-guard blocks a cross-repo
# subagent". Pinned: the regression is silent (a correct-looking BLOCKED banner).
payload_cwd() {
  python3 -c '
import json, sys
tool, val, key, cwd = sys.argv[1:5]
print(json.dumps({"tool_name": tool, "tool_input": {key: val}, "cwd": cwd}))
' "$1" "$2" "$3" "$4"
}

setup_symlinked_repo() {
  SGREAL="$BATS_TEST_TMPDIR/real"
  SGLINK="$BATS_TEST_TMPDIR/link"
  mkdir -p "$SGREAL/r"
  git -C "$SGREAL/r" init -q
  ln -sfn "$SGREAL" "$SGLINK"
}

@test "allows an in-repo search when the repo is reached through a symlinked prefix" {
  setup_symlinked_repo
  PAYLOAD="$(payload_cwd Bash "find $SGLINK/r -name '*.rb'" command "$SGLINK/r")"
  run_hook
  [ "$status" -eq 0 ]
}

@test "still blocks an out-of-repo search when the repo is reached through a symlink" {
  setup_symlinked_repo
  mkdir -p "$SGREAL/elsewhere"
  PAYLOAD="$(payload_cwd Bash "find $SGREAL/elsewhere -name '*.rb'" command "$SGLINK/r")"
  run_hook
  [ "$status" -eq 2 ]
}

@test "block message states the opt-out cannot be a command prefix" {
  run_bash "find / -name foo"
  [ "$status" -eq 2 ]
  [[ "$output" == *"prefix cannot work"* ]]
}
