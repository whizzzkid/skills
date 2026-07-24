#!/usr/bin/env bash
# PreToolUse hook: keep tool calls inside the project scope.
#
# Reads the tool's JSON input from stdin. Two guards:
#   1. Bash  — BLOCK (exit 2) a filesystem-root search (`find /`, `grep -r … /`,
#              `rg … /`) or any recursive search rooted outside the repo. This is
#              the recurring "what are you looking for outside the scope of the
#              project?" failure.
#   2. Edit/Write/MultiEdit — WARN (exit 0, never block) when the target file is
#              an absolute path outside the repo root. Writing outside the repo
#              (e.g. $HOME/.claude/settings.json) is sometimes legitimate, so this
#              nudges rather than blocks.
#
# Opt out per-session with SCOPE_GUARD_OFF=1.
# Exit codes: 0 = allow (stderr shown as context), 2 = block (stderr shown to Claude).
#
# Best-effort, not airtight. This is a nudge against accidental scope creep,
# not a security boundary — the agent can always set SCOPE_GUARD_OFF=1. It does
# lexical token inspection and deliberately does NOT shell-expand the command,
# so it does not catch: a prior `cd /outside && find .`, search roots from a
# variable or command substitution (`find $HOME`, `find "$(…)"`), or an in-repo
# symlink that points outside. Those slip through by design; the guard targets
# the common literal-path case (`find /`, `grep -r … /etc`).

set -uo pipefail

[ "${SCOPE_GUARD_OFF:-}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null) || exit 0
[ -z "$INPUT" ] && exit 0

# -- Parse the fields we need from the hook payload (one python call each) -----
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
print(d.get("tool_name",""))' 2>/dev/null)
[ -z "$TOOL_NAME" ] && exit 0

CWD=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
print(d.get("cwd",""))' 2>/dev/null)
[ -z "$CWD" ] && CWD="$PWD"

# -- Resolve repo root; if not a git repo we cannot reason about scope --------
REPO_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -z "$REPO_ROOT" ] && exit 0

# is_outside <abs-path> -> 0 (true, outside repo) / 1 (inside or relative)
is_outside() {
  local p="$1"
  case "$p" in
    /*) : ;;            # absolute — check it
    *)  return 1 ;;     # relative — resolved against cwd, treat as inside
  esac
  # Normalize without requiring the path to exist (lexical: collapses `..`).
  local norm
  norm=$(cd / && python3 -c 'import os,sys; print(os.path.normpath(sys.argv[1]))' "$p" 2>/dev/null) || norm="$p"
  # Glob-safe prefix test (a `case` glob would mis-handle a repo path that
  # itself contains [ ] * ? — and the trailing slash keeps /a/skills from
  # matching the sibling /a/skills-foo).
  [ "$norm" = "$REPO_ROOT" ] && return 1
  [ "${norm#"$REPO_ROOT"/}" != "$norm" ] && return 1  # inside repo
  return 0                                             # outside repo
}

case "$TOOL_NAME" in
  Bash)
    CMD=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
print(d.get("tool_input",{}).get("command",""))' 2>/dev/null)
    [ -z "$CMD" ] && exit 0

    # Only a recursive/filesystem search is in scope for this guard:
    #   find … | fd … | grep -r/-R … | rg … (recursive by default) | ls -R …
    is_search=1
    printf '%s' "$CMD" | grep -qE '(^|[ ;|&(])(find|fd|rg)([ ]|$)' && is_search=0
    printf '%s' "$CMD" | grep -qE 'grep[ ]+(-[^ ]*[ ]+)*(-[A-Za-z]*[rR]|--recursive)' && is_search=0
    printf '%s' "$CMD" | grep -qE 'ls[ ]+(-[^ ]*[ ]+)*-[A-Za-z]*R' && is_search=0
    [ "$is_search" -ne 0 ] && exit 0

    # Block only when a search-root *path argument* is "/" or resolves outside
    # the repo. Absolute paths INSIDE the repo are fine; relative paths resolve
    # against cwd (inside) and are fine. This is the key false-positive guard.
    # Tokenize quote-aware (no glob expansion of the raw command). A plain
    # whitespace split turns prose inside a quoted string into path-shaped
    # fragments, so a `/` used as a word separator in an `echo` banner reads as
    # a filesystem-root search argument and false-blocks the whole compound
    # command. shlex keeps a quoted string as ONE token while still unwrapping a
    # genuinely quoted root (`find "/etc"`), so no true positive is relaxed.
    # Unbalanced quotes raise — fall back to the whitespace split rather than
    # skipping the check (fail closed).
    offending=""
    _toks=()
    _tokenized=0
    while IFS= read -r -d '' tok; do _toks+=("$tok"); _tokenized=1; done < <(
      printf '%s' "$CMD" | python3 -c 'import shlex,sys
cmd = sys.stdin.read()
try: toks = shlex.split(cmd)
except ValueError: toks = cmd.split()
sys.stdout.write("".join(t + "\0" for t in toks))' 2>/dev/null)
    [ "$_tokenized" -eq 0 ] && read -ra _toks <<<"$CMD"

    for tok in ${_toks[@]+"${_toks[@]}"}; do
      # Strip surrounding quotes — a no-op on shlex output, load-bearing on the
      # whitespace fallback so a quoted root like find "/etc" is still inspected.
      tok="${tok#[\"\']}"; tok="${tok%[\"\']}"
      # Strip trailing shell separators glued to the token. `cd /repo; find …`
      # tokenizes as `/repo;`, which matches neither the repo root nor its
      # prefix, so the in-repo path reads as outside and the call is blocked.
      # Stripping sharpens the comparison both ways: `/etc;` still blocks.
      tok="${tok%%[;&|)]*}"
      [ -z "$tok" ] && continue
      case "$tok" in
        /) offending="/" ; break ;;
        /*) if is_outside "$tok"; then offending="$tok"; break; fi ;;
      esac
    done

    if [ -n "$offending" ]; then
      {
        echo "┌─ scope-guard: BLOCKED search outside the project root"
        echo "│  Command:   ${CMD:0:160}"
        echo "│  Out-of-scope path: $offending"
        echo "│  Repo root: $REPO_ROOT"
        echo "│  Grep within the repo, or the tool-managed dependency path"
        echo "│  (\`bundle show <gem>\`, \`mise where\`, \`go env GOMODCACHE\`)."
        echo "└─ If this is genuinely required, set SCOPE_GUARD_OFF=1 for the session."
      } >&2
      exit 2
    fi
    exit 0
    ;;

  Edit|Write|MultiEdit|NotebookEdit)
    FP=$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
ti=d.get("tool_input",{})
print(ti.get("file_path") or ti.get("notebook_path") or "")' 2>/dev/null)
    [ -z "$FP" ] && exit 0
    if is_outside "$FP"; then
      {
        echo "┌─ scope-guard: WARNING — writing outside the project root"
        echo "│  Target: $FP"
        echo "│  Repo:   $REPO_ROOT"
        echo "│  Confirm this is intentional (e.g. $HOME/.claude config) and not scope creep."
        echo "└─ Not blocked. Set SCOPE_GUARD_OFF=1 to silence."
      } >&2
    fi
    exit 0
    ;;

  *)
    exit 0
    ;;
esac
