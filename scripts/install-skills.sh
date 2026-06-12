#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
npx skills add . -g -y -a=claude

# Wire the skill-shipped hooks into $HOME/.claude/settings.json (idempotent).
"$(dirname "$0")/register-hooks.sh"
