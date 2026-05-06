#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
npx skills add . -g -y -a=claude
