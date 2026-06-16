---
skill: wk-sitrep
date: 2026-06-16
type: gap
severity: medium
---

Read `.sitrep.yml` from the git repo root for local config overrides before falling back to env vars or defaults.

**What happened:** `$SITREP_PORT` was not set in the environment, so the skill defaulted to port 3000. The actual host port (mapped in docker-compose) was different, so every generated `open` URL and announcement link pointed to the wrong port.

**Root cause:** The skill's Step 0 bootstrap only reads env vars (`$SITREP_REPO`, `$EMPLOYER`, `$SITREP_PORT`). No provision for a per-project config file that travels with the repo, so engineers who don't export these vars in their shell profile silently get wrong defaults.

**Suggested fix:** In Step 0 bootstrap, after setting defaults, probe `$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)/.sitrep.yml`. If found, parse it with `yq` (or `grep`/`sed` if `yq` unavailable) and override only the keys present. Resolution order: `.sitrep.yml` → env var → skill default. This lets per-project config live alongside the repo without requiring shell profile exports.

```bash
_REPO_ROOT=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)
_CFG="$_REPO_ROOT/.sitrep.yml"
if [ -f "$_CFG" ]; then
  _port=$(grep -E '^sitrep_port:' "$_CFG" | awk '{print $2}' | tr -d '"')
  _employer=$(grep -E '^employer:' "$_CFG" | awk '{print $2}' | tr -d '"')
  _repo=$(grep -E '^sitrep_repo:' "$_CFG" | awk '{print $2}' | tr -d '"')
  [ -n "$_port" ]     && SITREP_PORT="$_port"
  [ -n "$_employer" ] && EMPLOYER="$_employer"
  [ -n "$_repo" ]     && SITREP_REPO="$_repo"
fi
```
