#!/usr/bin/env bash
# check-ticket-refs.sh — block internal project/ticket IDs from public commits.
#
# This repo is employer/user/environment/tooling agnostic. Internal tracker
# ticket keys (any PREFIX-NNN board reference) leak the org's tracker and pin
# a learning to one incident. Use the generic placeholder `BOARD-NUM` instead.
#
# Design: detect the GENERIC ticket shape `[A-Z]{2,}-[0-9]+` and block anything
# that is not on a small allowlist of public, standards-based tokens. No
# internal board name is embedded in this file (embedding it would itself leak
# the name); new internal boards are caught automatically.
#
# Runs as a lefthook pre-commit step. Exits non-zero on a staged ADDED line that
# introduces a non-allowlisted ticket-shaped token.

set -euo pipefail

# Public, standards-based tokens that share the PREFIX-NUM shape but are NOT
# tracker tickets. Extend only with universally-safe (non-org) tokens.
ALLOW='^(UTF-(8|16|32)|ISO-[0-9]+|SHA-(1|256|512)|BASE-64|RFC-[0-9]+|BOARD-[0-9]+|HTTP-[0-9]+)$'

# Inspect only staged ADDED lines in the cached diff.
added=$(git diff --cached --unified=0 --no-color \
  | grep -E '^\+' | grep -vE '^\+\+\+' || true)

[[ -z "$added" ]] && exit 0

hits=$(printf '%s\n' "$added" \
  | grep -oE '\b[A-Z]{2,}-[0-9]+\b' \
  | grep -vE "$ALLOW" \
  | sort -u || true)

if [[ -n "$hits" ]]; then
  echo "✗ pre-commit: ticket-shaped token(s) in staged diff — likely an internal tracker ID" >&2
  echo "" >&2
  printf '%s\n' "$hits" | sed 's/^/  /' >&2
  echo "" >&2
  echo "Fix: replace internal ticket keys with the generic placeholder BOARD-NUM." >&2
  echo "This repo is public and org-agnostic — see AGENTS.md 'Public Repo'." >&2
  echo "If this is a genuine public standard, add it to ALLOW in this hook." >&2
  exit 1
fi

exit 0
