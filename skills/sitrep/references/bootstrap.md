---
class: recipe
---

# Step 0 bootstrap recipes

Canonical env/path resolution and SilverBullet start probe for both sub-commands.

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
fi

test -n "$SITREP_REPO" || { echo "SITREP_REPO is not set"; exit 1; }
test -n "$EMPLOYER"    || { echo "EMPLOYER is not set"; exit 1; }
SITREP_PORT="${SITREP_PORT:-3000}"

TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y); WEEK=$(date +%V)
LIVE_FILE="$SITREP_REPO/$EMPLOYER/live.md"
SNAPSHOT_DIR="$SITREP_REPO/$EMPLOYER/$(date +%Y)/$(date +%m)/$(date +%d)"
SNAPSHOT_FILE="$SNAPSHOT_DIR/snapshot.md"
WEEK_MEM_FILE="$SITREP_REPO/$EMPLOYER/.dismissed/$YEAR-W$WEEK.jsonl"

mkdir -p "$SITREP_REPO/$EMPLOYER" "$SNAPSHOT_DIR" "$(dirname "$WEEK_MEM_FILE")"
```

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
