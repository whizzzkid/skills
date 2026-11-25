#!/usr/bin/env bats
# Tests for the wk-sharpen watch-mode subscriber (scripts/watch-queue.sh).
# Run: bats skills/sharpen/tests/watch-queue.bats
#
# Every assertion carries an explicit `|| return 1` so a failing assertion that is
# not the last command in a body still fails the test.

setup() {
  SCRIPT="${BATS_TEST_DIRNAME}/../scripts/watch-queue.sh"
  FIX="$BATS_TEST_TMPDIR/fixture"
  export HOME="$FIX/home"
  export WK_SKILLS_HOME="$FIX/repo"
  mkdir -p "$HOME/.claude/skills/learnings" "$WK_SKILLS_HOME/learnings/skills/demo" "$WK_SKILLS_HOME/learnings/retrospect"
  git -C "$WK_SKILLS_HOME" init -q
  export WK_SHARPEN_SETTLE_SECONDS=0
  export WK_SHARPEN_RECHECK_SECONDS=30
  export WK_SHARPEN_LOCK_POLL_SECONDS=1
  unset WK_SHARPEN_LOCK_TTL_SECONDS
  FAKE_BIN="$FIX/bin"
  mkdir -p "$FAKE_BIN"
  BASE_PATH="/usr/bin:/bin"
}

# Writes a fake watcher named $1 whose body is $2, and puts only it plus system dirs on PATH.
fake_watcher() {
  printf '#!/bin/bash\n%s\n' "$2" >"$FAKE_BIN/$1"
  chmod +x "$FAKE_BIN/$1"
  export PATH="$FAKE_BIN:$BASE_PATH"
}

# Plants file $1 after $2 seconds, detached from bats' output fds.
plant_later() {
  (sleep "$2"; mkdir -p "$(dirname "$1")"; printf 'x\n' >"$1") >/dev/null 2>&1 3>&- &
}

@test "pending counts unprocessed learnings across all three sources, ignoring .learned.md" {
  printf 'x' >"$WK_SKILLS_HOME/learnings/skills/demo/a.md"
  printf 'x' >"$WK_SKILLS_HOME/learnings/skills/demo/b.learned.md"
  printf 'x' >"$WK_SKILLS_HOME/learnings/retrospect/r.md"
  printf 'x' >"$HOME/.claude/skills/learnings/inbox.md"
  run "$SCRIPT" pending
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "3" ] || return 1
}

@test "pending follows a symlinked skill directory" {
  mkdir -p "$FIX/elsewhere"
  printf 'x' >"$FIX/elsewhere/c.md"
  ln -s "$FIX/elsewhere" "$WK_SKILLS_HOME/learnings/skills/linked"
  run "$SCRIPT" pending
  [ "$output" = "1" ] || return 1
}

@test "pending is 0 when no queue directory exists" {
  rm -rf "$WK_SKILLS_HOME/learnings" "$HOME/.claude/skills/learnings"
  run "$SCRIPT" pending
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "0" ] || return 1
}

@test "wait returns immediately when work is already queued (level-triggered)" {
  fake_watcher fswatch 'sleep 1000'
  printf 'x' >"$WK_SKILLS_HOME/learnings/skills/demo/a.md"
  run "$SCRIPT" wait
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "ARRIVED 1" ] || return 1
}

@test "wait fires on a real file arrival via fswatch" {
  if ! command -v fswatch >/dev/null; then skip "fswatch not installed"; fi
  plant_later "$WK_SKILLS_HOME/learnings/skills/demo/new.md" 3
  run "$SCRIPT" wait
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "ARRIVED 1" ] || return 1
}

@test "wait ignores a .learned.md arrival and fires on the next real learning" {
  if ! command -v fswatch >/dev/null; then skip "fswatch not installed"; fi
  plant_later "$WK_SKILLS_HOME/learnings/skills/demo/done.learned.md" 2
  plant_later "$WK_SKILLS_HOME/learnings/skills/demo/real.md" 5
  run "$SCRIPT" wait
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "ARRIVED 1" ] || return 1
  [ -f "$WK_SKILLS_HOME/learnings/skills/demo/real.md" ] || return 1
}

@test "wait catches an arrival the watcher missed via the periodic recheck" {
  # This watcher never reports an event, so only the recheck timer can notice the file.
  fake_watcher fswatch 'exec sleep 1000'
  export WK_SHARPEN_RECHECK_SECONDS=2
  plant_later "$WK_SKILLS_HOME/learnings/skills/demo/dropped.md" 2
  run "$SCRIPT" wait
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "ARRIVED 1" ] || return 1
}

@test "wait falls back to inotifywait when fswatch is absent" {
  fake_watcher inotifywait 'exec sleep 1000'
  export WK_SHARPEN_RECHECK_SECONDS=2
  plant_later "$WK_SKILLS_HOME/learnings/skills/demo/linux.md" 2
  run "$SCRIPT" wait
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "ARRIVED 1" ] || return 1
}

@test "wait exits 3 WATCHER_UNAVAILABLE when no watcher is on PATH" {
  export PATH="$BASE_PATH"
  if command -v fswatch >/dev/null || command -v inotifywait >/dev/null; then skip "a watcher is on the base PATH"; fi
  run "$SCRIPT" wait
  [ "$status" -eq 3 ] || return 1
  [ "$output" = "WATCHER_UNAVAILABLE" ] || return 1
}

@test "wait exits 4 WATCHER_FAILED when the watcher errors with an empty queue" {
  fake_watcher fswatch 'exit 1'
  run "$SCRIPT" wait
  [ "$status" -eq 4 ] || return 1
  [[ "$output" == "WATCHER_FAILED fswatch rc=1" ]] || return 1
}

@test "wait exits 2 when WK_SKILLS_HOME is unset" {
  unset WK_SKILLS_HOME
  run "$SCRIPT" wait
  [ "$status" -eq 2 ] || return 1
}

@test "wait exits 2 when no queue directory exists" {
  fake_watcher fswatch 'sleep 1000'
  rm -rf "$WK_SKILLS_HOME/learnings" "$HOME/.claude/skills/learnings"
  run "$SCRIPT" wait
  [ "$status" -eq 2 ] || return 1
}

@test "wait holds while another session holds the lock, then fires on release" {
  fake_watcher fswatch 'sleep 1000'
  printf 'x' >"$WK_SKILLS_HOME/learnings/skills/demo/a.md"
  "$SCRIPT" lock peer >/dev/null
  (sleep 3; "$SCRIPT" unlock peer) >/dev/null 2>&1 3>&- &
  start=$(date +%s)
  run "$SCRIPT" wait
  elapsed=$(($(date +%s) - start))
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "ARRIVED 1" ] || return 1
  [ "$elapsed" -ge 3 ] || return 1
}

@test "lock is exclusive and records its owner" {
  run "$SCRIPT" lock alpha
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "LOCK_ACQUIRED" ] || return 1
  run "$SCRIPT" lock beta
  [ "$status" -eq 1 ] || return 1
  [[ "$output" == "LOCK_HELD owner=alpha age="* ]] || return 1
}

@test "lock lives in the git dir, never the work tree" {
  "$SCRIPT" lock alpha >/dev/null
  [ -d "$WK_SKILLS_HOME/.git/wk-sharpen.lock" ] || return 1
  [ -z "$(git -C "$WK_SKILLS_HOME" status --porcelain)" ] || return 1
}

@test "unlock refuses a non-owner and releases for the owner" {
  "$SCRIPT" lock alpha >/dev/null
  run "$SCRIPT" unlock beta
  [ "$status" -eq 1 ] || return 1
  [ "$output" = "LOCK_OWNED_BY_OTHER owner=alpha" ] || return 1
  run "$SCRIPT" unlock alpha
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "LOCK_RELEASED" ] || return 1
  [ ! -d "$WK_SKILLS_HOME/.git/wk-sharpen.lock" ] || return 1
}

@test "unlock with no lock is idempotent" {
  run "$SCRIPT" unlock alpha
  [ "$status" -eq 0 ] || return 1
  [ "$output" = "LOCK_NOT_HELD" ] || return 1
}

@test "a lock older than the TTL is reclaimed" {
  "$SCRIPT" lock crashed >/dev/null
  printf 'owner=crashed\nacquired_at=%s\n' "$(($(date +%s) - 20000))" >"$WK_SKILLS_HOME/.git/wk-sharpen.lock/info"
  run "$SCRIPT" lock alpha
  [ "$status" -eq 0 ] || return 1
  [ "${lines[0]}" = "LOCK_RECLAIMED" ] || return 1
  [ "${lines[1]}" = "LOCK_ACQUIRED" ] || return 1
}

@test "a lock dir with no info file counts as held (mid-acquire)" {
  mkdir "$WK_SKILLS_HOME/.git/wk-sharpen.lock"
  run "$SCRIPT" lock alpha
  [ "$status" -eq 1 ] || return 1
}

@test "lock and unlock require an owner" {
  run "$SCRIPT" lock
  [ "$status" -eq 2 ] || return 1
  run "$SCRIPT" unlock
  [ "$status" -eq 2 ] || return 1
}

@test "lock exits 2 outside a git repository" {
  rm -rf "$WK_SKILLS_HOME/.git"
  export GIT_CEILING_DIRECTORIES="$FIX"
  run "$SCRIPT" lock alpha
  [ "$status" -eq 2 ] || return 1
}

@test "unknown subcommand exits 2 with usage" {
  run "$SCRIPT" bogus
  [ "$status" -eq 2 ] || return 1
  [[ "$output" == *"usage:"* ]] || return 1
}
