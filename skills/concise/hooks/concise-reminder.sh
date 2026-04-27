#!/bin/sh
# concise-reminder — per-turn reinforcement for wk:concise
#
# Emits a 1-line reminder on each UserPromptSubmit so the active mode
# (brief|dense) stays top-of-mind. Pure POSIX sh, no dependencies.
#
# Opt-out precedence (evaluated top-to-bottom):
#   1. $CONCISE_OFF=1 environment variable
#   2. ~/.claude/.concise-off flag file exists
#   3. ~/.claude/.concise-mode contents = "off"
#
# Otherwise, reads mode from ~/.claude/.concise-mode (default: brief).
#
# Install — add to ~/.claude/settings.json:
#   {
#     "hooks": {
#       "UserPromptSubmit": [
#         { "matcher": "",
#           "hooks": [{
#             "type": "command",
#             "command": "$HOME/.agents/skills/wk-concise/hooks/concise-reminder.sh"
#           }] }
#       ]
#     }
#   }

set -eu

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
OFF_FLAG="$CONFIG_DIR/.concise-off"
MODE_FILE="$CONFIG_DIR/.concise-mode"

# Silent-fail on any IO error — hooks must never block sessions
( :
  [ "${CONCISE_OFF:-}" = "1" ] && exit 0
  [ -e "$OFF_FLAG" ] && exit 0

  MODE="brief"
  if [ -r "$MODE_FILE" ]; then
    # Read up to 16 bytes, strip whitespace, lowercase
    RAW=$(head -c 16 "$MODE_FILE" 2>/dev/null | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    case "$RAW" in
      off) exit 0 ;;
      brief|dense) MODE="$RAW" ;;
      *) MODE="brief" ;;  # unknown value → safe default
    esac
  fi

  case "$MODE" in
    brief)
      printf 'CONCISE MODE: brief. HARD CAPS — answer ≤3 sentences unless code/diff/safety. No tables for ≤3 items (use a sentence). No section headers for single-section answers. No trailing summary or "let me know if". Drop filler, hedging, pleasantries. Keep grammar. Code blocks and safety warnings stay verbose.\n'
      ;;
    dense)
      printf 'CONCISE MODE: dense. HARD CAPS — answer ≤2 sentences (or fragments) unless code/diff/safety. No tables for ≤4 items. No headers. Drop articles. Use → for causality. Short synonyms. Code blocks and safety warnings stay verbose.\n'
      ;;
  esac
) 2>/dev/null || true

exit 0
