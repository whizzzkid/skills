#!/usr/bin/env bash
# Idempotently merge the hooks declared in hooks-manifest.json into the
# Claude Code settings file. Safe to run repeatedly — an entry whose exact
# command string is already present is skipped, so this never duplicates.
#
# Override the target settings file with CLAUDE_SETTINGS (used by tests).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$SCRIPT_DIR/hooks-manifest.json"
SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"

[[ -f "$MANIFEST" ]] || { echo "register-hooks: manifest not found: $MANIFEST" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "register-hooks: python3 required" >&2; exit 1; }

MANIFEST="$MANIFEST" SETTINGS="$SETTINGS" python3 - <<'PY'
import json, os, shutil

manifest_path = os.environ["MANIFEST"]
settings_path = os.environ["SETTINGS"]

manifest = json.load(open(manifest_path))

if os.path.exists(settings_path):
    settings = json.load(open(settings_path))
    shutil.copy(settings_path, settings_path + ".bak")
else:
    os.makedirs(os.path.dirname(settings_path) or ".", exist_ok=True)
    settings = {}

hooks = settings.setdefault("hooks", {})
added = 0

for event, entries in manifest.items():
    if event.startswith("_"):  # skip _comment and similar metadata keys
        continue
    bucket = hooks.setdefault(event, [])
    present = {h.get("command") for e in bucket for h in e.get("hooks", [])}
    for entry in entries:
        cmd = entry["command"]
        if cmd in present:
            continue
        bucket.append({
            "matcher": entry["matcher"],
            "hooks": [{"type": "command", "command": cmd}],
        })
        present.add(cmd)
        added += 1
        print(f"  + {event} [{entry['matcher'] or 'all'}] -> {cmd[:60]}")

if added:
    json.dump(settings, open(settings_path, "w"), indent=2)
    open(settings_path, "a").write("\n")
    print(f"register-hooks: added {added} hook(s) to {settings_path} (backup: .bak)")
else:
    print(f"register-hooks: all hooks already present in {settings_path} — no change")
PY
