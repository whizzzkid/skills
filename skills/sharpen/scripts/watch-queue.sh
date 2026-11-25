#!/usr/bin/env bash
# watch-queue.sh — event-driven subscriber for the wk-sharpen learnings queue.
#
# Usage:
#   watch-queue.sh pending          print the unprocessed-learning count
#   watch-queue.sh wait             block until work is ready, then print "ARRIVED <n>"
#   watch-queue.sh lock <owner>     take the machine-wide drain lock
#   watch-queue.sh unlock <owner>   release the lock (only its owner may)
#
# Exit codes:
#   0  success (wait: work is ready; lock: acquired; unlock: released or not held)
#   1  lock held by another owner / unlock refused
#   2  usage or configuration error
#   3  WATCHER_UNAVAILABLE — neither fswatch nor inotifywait is on PATH
#   4  WATCHER_FAILED — the file watcher exited non-zero
#
# `wait` is level-triggered: a file event only prompts a re-list, and the queue
# listing decides readiness. Bash 3.2 compatible (macOS /bin/bash).
set -euo pipefail

readonly SETTLE_SECONDS="${WK_SHARPEN_SETTLE_SECONDS:-60}"
readonly RECHECK_SECONDS="${WK_SHARPEN_RECHECK_SECONDS:-900}"
readonly LOCK_POLL_SECONDS="${WK_SHARPEN_LOCK_POLL_SECONDS:-30}"
readonly LOCK_TTL_SECONDS="${WK_SHARPEN_LOCK_TTL_SECONDS:-14400}"
readonly ARM_GRACE_SECONDS=1
readonly LOCK_NAME="wk-sharpen.lock"

EXIT_HELD=1
EXIT_USAGE=2
EXIT_UNAVAILABLE=3
EXIT_FAILED=4

# Background pids cleaned up on exit; script scope so the trap can see them.
watcher_pid=""
timer_pid=""
dirs_file=""

cleanup() {
  if [[ -n "$timer_pid" ]]; then kill "$timer_pid" 2>/dev/null || true; fi
  if [[ -n "$watcher_pid" ]]; then kill "$watcher_pid" 2>/dev/null || true; fi
  if [[ -n "$dirs_file" ]]; then rm -f "$dirs_file"; fi
}
trap cleanup EXIT INT TERM

die() {
  local status="$1"
  shift
  printf '%s\n' "$*" >&2
  exit "$status"
}

# Fails with EXIT_USAGE unless WK_SKILLS_HOME names a directory.
require_home() {
  if [[ -z "${WK_SKILLS_HOME:-}" ]]; then die "$EXIT_USAGE" "WK_SKILLS_HOME is not set"; fi
  if [[ ! -d "$WK_SKILLS_HOME" ]]; then die "$EXIT_USAGE" "WK_SKILLS_HOME is not a directory: $WK_SKILLS_HOME"; fi
}

# Prints each existing queue directory (Source 1 inbox, Source 2, Source 4), one per line.
queue_dirs() {
  local queue_dir
  for queue_dir in \
    "$WK_SKILLS_HOME/learnings/skills" \
    "$WK_SKILLS_HOME/learnings/retrospect" \
    "$HOME/.claude/skills/learnings"; do
    if [[ -d "$queue_dir" ]]; then printf '%s\n' "$queue_dir"; fi
  done
}

# Prints the number of unprocessed learnings (*.md, not *.learned.md); follows symlinks.
pending_count() {
  local dirs
  dirs=$(queue_dirs)
  if [[ -z "$dirs" ]]; then
    printf '0\n'
    return 0
  fi
  local count=0 queue_dir found
  while IFS= read -r queue_dir; do
    found=$(find -L "$queue_dir" -type f -name '*.md' ! -name '*.learned.md' 2>/dev/null | wc -l | tr -d ' ')
    count=$((count + found))
  done <<<"$dirs"
  printf '%s\n' "$count"
}

# Prints the absolute lock directory inside the repo's common git dir (never committed).
lock_dir() {
  local git_dir
  git_dir=$(git -C "$WK_SKILLS_HOME" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    die "$EXIT_USAGE" "WK_SKILLS_HOME is not a git repository: $WK_SKILLS_HOME"
  printf '%s/%s\n' "$git_dir" "$LOCK_NAME"
}

# Prints the lock's age in seconds, or nothing when the lock is absent or unreadable.
lock_age() {
  local dir="$1" acquired_at
  acquired_at=$(sed -n 's/^acquired_at=//p' "$dir/info" 2>/dev/null || true)
  if [[ -z "$acquired_at" ]]; then return 0; fi
  printf '%s\n' "$(($(date +%s) - acquired_at))"
}

# Succeeds when a live (non-stale) lock exists.
lock_is_live() {
  local dir age
  dir=$(lock_dir)
  if [[ ! -d "$dir" ]]; then return 1; fi
  age=$(lock_age "$dir")
  # A lock dir without a readable info file is mid-acquire: treat it as live.
  if [[ -z "$age" ]]; then return 0; fi
  ((age < LOCK_TTL_SECONDS))
}

cmd_lock() {
  local owner="${1:-}"
  if [[ -z "$owner" ]]; then die "$EXIT_USAGE" "usage: watch-queue.sh lock <owner>"; fi
  require_home
  local dir age
  dir=$(lock_dir)
  if [[ -d "$dir" ]] && ! lock_is_live; then
    # Best-effort reclaim: the holder outlived the TTL, so its session is presumed dead.
    rm -rf "$dir"
    printf 'LOCK_RECLAIMED\n'
  fi
  if ! mkdir "$dir" 2>/dev/null; then
    age=$(lock_age "$dir")
    printf 'LOCK_HELD owner=%s age=%ss\n' "$(sed -n 's/^owner=//p' "$dir/info" 2>/dev/null || true)" "${age:-?}"
    exit "$EXIT_HELD"
  fi
  printf 'owner=%s\nacquired_at=%s\n' "$owner" "$(date +%s)" >"$dir/info"
  printf 'LOCK_ACQUIRED\n'
}

cmd_unlock() {
  local owner="${1:-}"
  if [[ -z "$owner" ]]; then die "$EXIT_USAGE" "usage: watch-queue.sh unlock <owner>"; fi
  require_home
  local dir holder
  dir=$(lock_dir)
  if [[ ! -d "$dir" ]]; then
    printf 'LOCK_NOT_HELD\n'
    return 0
  fi
  holder=$(sed -n 's/^owner=//p' "$dir/info" 2>/dev/null || true)
  if [[ "$holder" != "$owner" ]]; then
    printf 'LOCK_OWNED_BY_OTHER owner=%s\n' "$holder"
    exit "$EXIT_HELD"
  fi
  rm -rf "$dir"
  printf 'LOCK_RELEASED\n'
}

# Prints the name of the first available watcher, or nothing.
detect_watcher() {
  if command -v fswatch >/dev/null 2>&1; then
    printf 'fswatch\n'
  elif command -v inotifywait >/dev/null 2>&1; then
    printf 'inotifywait\n'
  fi
}

# Starts a one-event watcher on the queue dirs in the background; sets watcher_pid.
start_watcher() {
  local watcher="$1" dirs_file="$2"
  local -a dirs=()
  local queue_dir
  while IFS= read -r queue_dir; do dirs+=("$queue_dir"); done <"$dirs_file"
  if [[ "$watcher" == "fswatch" ]]; then
    fswatch -1 -r --event Created --event Renamed --event Updated --event MovedTo "${dirs[@]}" >/dev/null 2>&1 &
  else
    inotifywait -q -r -e create -e moved_to -e close_write "${dirs[@]}" >/dev/null 2>&1 &
  fi
  watcher_pid=$!
}

# Kills the watcher after RECHECK_SECONDS so a dropped event cannot stall the wait forever.
start_timer() {
  local target="$1"
  (
    sleep_pid=""
    trap 'kill "${sleep_pid:-}" 2>/dev/null; exit 0' TERM
    sleep "$RECHECK_SECONDS" &
    sleep_pid=$!
    wait "$sleep_pid"
    kill "$target" 2>/dev/null || true
  ) >/dev/null 2>&1 &
  timer_pid=$!
}

# Blocks until one watcher event, a periodic recheck, or an arrival that raced the arm.
wait_for_change() {
  local watcher="$1" dirs_file="$2" status=0
  start_watcher "$watcher" "$dirs_file"
  start_timer "$watcher_pid"
  # Close the arm race: a file written before the watcher subscribed emits no event.
  sleep "$ARM_GRACE_SECONDS"
  if (($(pending_count) > 0)); then
    kill "$watcher_pid" 2>/dev/null || true
  fi
  wait "$watcher_pid" || status=$?
  watcher_pid=""
  if kill -0 "$timer_pid" 2>/dev/null; then
    kill "$timer_pid" 2>/dev/null || true
    timer_pid=""
    # Watcher ended on its own: rc 0 is an event; non-zero is a failure unless work already arrived.
    if ((status != 0)) && (($(pending_count) == 0)); then
      printf 'WATCHER_FAILED %s rc=%s\n' "$watcher" "$status"
      exit "$EXIT_FAILED"
    fi
  fi
  timer_pid=""
}

cmd_wait() {
  require_home
  local watcher
  watcher=$(detect_watcher)
  if [[ -z "$watcher" ]]; then
    printf 'WATCHER_UNAVAILABLE\n'
    exit "$EXIT_UNAVAILABLE"
  fi
  dirs_file=$(mktemp)
  queue_dirs >"$dirs_file"
  if [[ ! -s "$dirs_file" ]]; then die "$EXIT_USAGE" "no queue directory exists under $WK_SKILLS_HOME/learnings"; fi
  while true; do
    if lock_is_live; then
      # Another session is draining; its renames would only wake us to a stale listing.
      sleep "$LOCK_POLL_SECONDS"
      continue
    fi
    if (($(pending_count) > 0)); then break; fi
    wait_for_change "$watcher" "$dirs_file"
  done
  # Settle so a burst (a retro writing several learnings) becomes one cycle.
  sleep "$SETTLE_SECONDS"
  printf 'ARRIVED %s\n' "$(pending_count)"
}

main() {
  local subcommand="${1:-}"
  if [[ $# -gt 0 ]]; then shift; fi
  case "$subcommand" in
    pending)
      require_home
      pending_count
      ;;
    wait) cmd_wait ;;
    lock) cmd_lock "$@" ;;
    unlock) cmd_unlock "$@" ;;
    *) die "$EXIT_USAGE" "usage: watch-queue.sh pending | wait | lock <owner> | unlock <owner>" ;;
  esac
}

main "$@"
