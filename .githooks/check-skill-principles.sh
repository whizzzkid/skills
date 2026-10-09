#!/usr/bin/env bash
# check-skill-principles.sh — run principle grader unit tests on staged skill changes.
#
# Pre-commit/pre-push gate: if any SKILL.md is staged, run the grader tests
# to ensure the heuristic checkers still pass. Does NOT call the LLM — only
# exercises the deterministic grader logic (tests/principles.test.ts, tests/loc.test.ts, tests/skills.test.ts).
#
# The full promptfoo eval (which calls the LLM) runs separately via:
#   npx promptfoo@0.124.1 eval -c benchmarks/promptfooconfig.yaml
#
# Requires Node ≥22.6.0 for --experimental-strip-types.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
BENCH_DIR="$REPO_ROOT/benchmarks"

# Only run if SKILL.md or benchmark files are staged
staged=$(git diff --cached --name-only --diff-filter=ACMR \
  | { grep -E '(SKILL\.md|^benchmarks/)' || true; })

[[ -z "$staged" ]] && exit 0

# Check Node version supports --experimental-strip-types
NODE_MAJOR=$(node --version | sed 's/v\([0-9]*\).*/\1/')
if (( NODE_MAJOR < 22 )); then
  echo "⚠ skill-principles: skipped (Node $NODE_MAJOR < 22, needs --experimental-strip-types)" >&2
  exit 0
fi

echo "▶ Running skill principle grader tests..." >&2

node --experimental-strip-types "$BENCH_DIR/tests/principles.test.ts" 2>&1 \
  | tail -5 >&2

node --experimental-strip-types "$BENCH_DIR/tests/loc.test.ts" 2>&1 \
  | tail -5 >&2

node --experimental-strip-types "$BENCH_DIR/tests/skills.test.ts" 2>&1 \
  | tail -5 >&2

echo "✓ Principle grader tests passed" >&2
