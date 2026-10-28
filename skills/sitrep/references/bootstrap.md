---
class: recipe
---

# Step 0 bootstrap recipes

Canonical env/path resolution, push-destination gate, and SilverBullet start probe for both sub-commands.

## Verify environment and paths

Resolution order for each key: `.sitrep.yml` at the working repo root → env var →
skill default. The config probe runs first so per-project config can supply the
vars without shell-profile exports.

```bash
# Per-project overrides: .sitrep.yml at the working repo root wins over env/defaults.
_CFG="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)/.sitrep.yml"
if [ -f "$_CFG" ]; then
  _yml() { sed -n "s/^$1:[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}[[:space:]]*\$/\1/p" "$_CFG"; }
  _v=$(_yml sitrep_repo); [ -n "$_v" ] && SITREP_REPO="$_v"
  _v=$(_yml employer);    [ -n "$_v" ] && EMPLOYER="$_v"
  _v=$(_yml sitrep_port); [ -n "$_v" ] && SITREP_PORT="$_v"
  # Comma-separated connector domains the user waived for all runs, e.g. "lattice, jira".
  WAIVED_CONNECTORS=$(_yml waived_connectors)
  # Comma-separated remote owners (orgs) approved to receive pushes, e.g. "my-employer-org".
  PUSH_OWNERS=$(_yml push_owners)
fi

test -n "$SITREP_REPO" || { echo "SITREP_REPO is not set"; exit 1; }
# Relative sitrep_repo resolves against the .sitrep.yml directory (else cwd); absolute paths keep
# `git -C "$SITREP_REPO" add "$LIVE_FILE"` from doubling the prefix when the git toplevel is a parent.
_BASE="$PWD"; [ -f "$_CFG" ] && _BASE="$(dirname "$_CFG")"
case "$SITREP_REPO" in /*) ;; *) SITREP_REPO="$_BASE/$SITREP_REPO" ;; esac
SITREP_REPO=$(cd "$SITREP_REPO" && pwd -P) || { echo "SITREP_REPO does not exist"; exit 1; }
test -n "$EMPLOYER"    || { echo "EMPLOYER is not set"; exit 1; }
SITREP_PORT="${SITREP_PORT:-3000}"

TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y); MONTH=$(date +%m); DAY=$(date +%d); WEEK=$(date +%V)
LIVE_FILE="$SITREP_REPO/$EMPLOYER/live.md"
SNAPSHOT_DIR="$SITREP_REPO/$EMPLOYER/$YEAR/$MONTH/$DAY"
SNAPSHOT_FILE="$SNAPSHOT_DIR/snapshot.md"
SNAPSHOT_URL="http://localhost:$SITREP_PORT/$EMPLOYER/$YEAR/$MONTH/$DAY/snapshot"
WEEK_MEM_FILE="$SITREP_REPO/$EMPLOYER/.dismissed/$YEAR-W$WEEK.jsonl"

mkdir -p "$SITREP_REPO/$EMPLOYER" "$SNAPSHOT_DIR" "$(dirname "$WEEK_MEM_FILE")"
```

## Verify push destination

Fail closed: `PUSH_ALLOWED=1` only when `origin`'s owner is in the approved set (`push_owners:`, else
`$GITHUB_ORG`). Empty set, no `origin`, a local-path remote, or any other owner → `0`. Visibility is not a
criterion — a private repo under a personal account is still a personal destination.

```bash
PUSH_OWNERS="${PUSH_OWNERS:-$GITHUB_ORG}"
_OWNER=$(git -C "$SITREP_REPO" remote get-url origin 2>/dev/null \
  | sed -E 's#^[A-Za-z+]+://([^@/]+@)?[^/]+/##; s#^[^@/]+@[^:]+:##; s#/.*##')
PUSH_ALLOWED=0
if [ -n "$_OWNER" ] && printf ',%s,\n' "$PUSH_OWNERS" | sed 's/[[:space:]]//g' \
    | command grep -qiF -- ",$_OWNER,"; then
  PUSH_ALLOWED=1
fi
```

- `PUSH_ALLOWED=0` → still commit locally; skip every `git push` this run; tell the user the remote owner
  (`$_OWNER`, or "none") is not approved and to move the repo to an employer-managed org, then add that org to
  `push_owners:`. Never add the current owner to the list on the user's behalf.

## Verify SilverBullet is running

```bash
if ! pgrep -f "silverbullet" > /dev/null 2>&1; then
  if docker ps --filter name=silverbullet --format '{{.Names}}' 2>/dev/null | grep -q .; then
    :  # already served by a docker-compose deployment — treat as running
  elif command -v silverbullet >/dev/null 2>&1; then
    silverbullet "$SITREP_REPO" &
    sleep 2
  else
    echo "SilverBullet is not installed. Install it, run: silverbullet $SITREP_REPO, then re-run."
    exit 1
  fi
fi
```
