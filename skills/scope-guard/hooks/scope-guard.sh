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
# so it does not catch: a prior `cd /outside && find .`, or search roots from a
# variable or command substitution (`find $HOME`, `find "$(…)"`). Those slip
# through by design; the guard targets the common literal-path case (`find /`,
# `grep -r … /etc`). Literal path operands ARE symlink-resolved before the
# in-repo comparison, so a repo reached through a symlinked prefix (macOS
# /tmp -> /private/tmp) is not false-blocked, and an in-repo symlink pointing
# outside resolves outside and blocks.

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
  # Resolve symlinks on BOTH sides before comparing. `git rev-parse` always
  # reports the PHYSICAL root (/private/tmp/r), while an operand keeps whatever
  # logical prefix the caller typed (/tmp/r) — on macOS /tmp, /var and /etc are
  # symlinks, so a lexical compare judges an entirely in-repo search "outside"
  # and false-blocks it. realpath resolves the existing prefix and keeps any
  # non-existent tail, so it still works for paths that do not exist yet.
  # This only ever tightens the guard: an in-repo symlink pointing outside now
  # resolves outside and blocks, where the old lexical compare let it through.
  local norm
  norm=$(cd / && python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$p" 2>/dev/null) \
    || norm=$(cd / && python3 -c 'import os,sys; print(os.path.normpath(sys.argv[1]))' "$p" 2>/dev/null) \
    || norm="$p"
  local root
  root=$(cd / && python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$REPO_ROOT" 2>/dev/null) \
    || root="$REPO_ROOT"
  # Glob-safe prefix test (a `case` glob would mis-handle a repo path that
  # itself contains [ ] * ? — and the trailing slash keeps /a/skills from
  # matching the sibling /a/skills-foo).
  [ "$norm" = "$root" ] && return 1
  [ "${norm#"$root"/}" != "$norm" ] && return 1  # inside repo
  return 0                                       # outside repo
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
    #
    # Scope-check ONLY the *path operands* of such an invocation. Two shapes
    # false-block an entirely in-repo command when every absolute-looking token
    # is charged as a search root instead:
    #   1. A search tool's own PATTERN operand carries path-shaped text — a
    #      scrub check greps repo-relative files FOR absolute-path shapes.
    #   2. A compound command pairs one search with unrelated commands whose
    #      arguments are not search roots at all.
    # So: segment the command at shell separators, classify each segment by its
    # own argv under that tool's grammar, and emit only its path operands. This
    # does not relax the matcher — a genuine out-of-repo root is still a path
    # operand and still blocks.
    #
    # Tokenize quote-aware (no glob expansion). shlex keeps a quoted string as
    # ONE token while still unwrapping a genuinely quoted root (`find "/etc"`).
    # Unbalanced quotes raise — fall back to a whitespace split rather than
    # skipping the check (fail closed). A `__OK__` sentinel distinguishes "python
    # ran and found no path operands" from "python unavailable"; without it the
    # bash whole-string scan below runs so the guard never fails open.
    offending=""
    candidates=()
    _parsed=0
    while IFS= read -r -d '' tok; do
      if [ "$tok" = "__OK__" ]; then _parsed=1; continue; fi
      candidates+=("$tok")
    done < <(
      printf '%s' "$CMD" | python3 -c '
import shlex, sys

SEPS = {";", "&&", "||", "|", "&"}
# Tools whose FIRST positional operand is the pattern, not a path.
PATTERN_FIRST = {"grep", "egrep", "fgrep", "rg", "ag", "ack"}
# Long/short flags whose NEXT token is a value, never a search root.
VALUE_FLAGS = {
    "-e", "--regexp", "-f", "--file", "-m", "--max-count", "--include",
    "--exclude", "--exclude-dir", "-A", "-B", "-C", "-D", "-d", "-g",
    "--glob", "-t", "-T", "--type", "--type-not",
}
PATTERN_FLAGS = {"-e", "--regexp", "-f", "--file"}

cmd = sys.stdin.read()
try:
    toks = shlex.split(cmd)
except ValueError:
    toks = cmd.split()

# Split into command segments; a separator may be glued to a token end.
segs, cur = [], []
for t in toks:
    if t in SEPS:
        segs.append(cur)
        cur = []
        continue
    core = t.rstrip(";&|")
    if core != t:
        if core:
            cur.append(core)
        segs.append(cur)
        cur = []
        continue
    cur.append(t)
segs.append(cur)

out = []
pending_cd = []
for seg in segs:
    i = 0
    # Skip VAR=value prefixes to reach the real command name.
    while i < len(seg) and not seg[i].startswith("-") and "=" in seg[i] \
            and "/" not in seg[i].split("=", 1)[0]:
        i += 1
    if i >= len(seg):
        continue
    name = seg[i].rsplit("/", 1)[-1]
    args = seg[i + 1:]

    # A cd/pushd outside the repo changes the EFFECTIVE root of any search that
    # follows (`cd <outside> && grep -r x .` searches outside while naming only
    # `.`). Per-segment classification alone would let that through, so charge a
    # preceding cd target against the first in-scope search after it.
    if name in ("cd", "pushd"):
        pending_cd.extend(a for a in args if not a.startswith("-"))
        continue
    flags = [a for a in args if a.startswith("-") and a != "-"]
    shorts = [f for f in flags if not f.startswith("--")]

    # stop_at_flag: find/fd take paths BEFORE the expression, so the first
    # flag ends the path list (`-name x` is an expression, not a root).
    if name in ("find", "fd"):
        in_scope, stop_at_flag, value_short = True, True, ""
    elif name in ("grep", "egrep", "fgrep"):
        in_scope = any(f in ("--recursive", "-R") for f in flags) or \
            any("r" in f or "R" in f for f in shorts)
        stop_at_flag, value_short = False, "efmABCDd"
    elif name in ("rg", "ag", "ack"):
        in_scope, stop_at_flag, value_short = True, False, "efgtTmABC"
    elif name == "ls":
        in_scope = any("R" in f for f in shorts)
        stop_at_flag, value_short = False, ""
    else:
        continue
    if not in_scope:
        continue

    out.extend(pending_cd)
    pending_cd = []

    # A positional pattern is consumed only by a pattern-first tool that did
    # not already get its pattern from -e/-f.
    pattern_taken = name not in PATTERN_FIRST or any(
        a.split("=", 1)[0] in PATTERN_FLAGS or
        (a.startswith("-") and not a.startswith("--") and a[-1:] in ("e", "f"))
        for a in flags
    )

    skip_next = False
    for a in args:
        if skip_next:
            skip_next = False
            continue
        if a.startswith("-") and a != "-":
            if stop_at_flag:
                break
            base = a.split("=", 1)[0]
            if "=" in a:
                pass
            elif base in VALUE_FLAGS:
                skip_next = True
            elif not a.startswith("--") and value_short and a[-1] in value_short:
                skip_next = True
            continue
        if not pattern_taken:
            pattern_taken = True
            continue
        out.append(a)

sys.stdout.write("__OK__\0")
sys.stdout.write("".join(p + "\0" for p in out))
' 2>/dev/null)

    # python3 unavailable → fall back to scanning every whitespace token of the
    # whole command (the pre-role-classification behavior): noisier, but closed.
    if [ "$_parsed" -eq 0 ]; then
      printf '%s' "$CMD" | grep -qE '(^|[ ;|&(])(find|fd|rg)([ ]|$)|grep[ ]+(-[^ ]*[ ]+)*(-[A-Za-z]*[rR]|--recursive)|ls[ ]+(-[^ ]*[ ]+)*-[A-Za-z]*R' || exit 0
      read -ra candidates <<<"$CMD"
    fi

    for tok in ${candidates[@]+"${candidates[@]}"}; do
      # Strip surrounding quotes — a no-op on shlex output, load-bearing on the
      # whitespace fallback so a quoted root like find "/etc" is still inspected.
      tok="${tok#[\"\']}"; tok="${tok%[\"\']}"
      # Strip trailing shell separators glued to the token (`/repo;` from a
      # `cd /repo; find …` prefix would otherwise read as outside the repo).
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
        echo "│  Working in another repo? Root this agent's session there — the"
        echo "│  boundary is the repo of the session cwd, not the calling repo."
        echo "└─ Ask the user for SCOPE_GUARD_OFF=1 in the session env; a"
        echo "   \`SCOPE_GUARD_OFF=1 <cmd>\` prefix cannot work (this hook runs first)."
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
