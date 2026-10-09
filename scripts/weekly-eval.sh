#!/usr/bin/env bash
# weekly-eval.sh — run both promptfoo suites and compare against the previous run.
#
# Catches silent skill atrophy (a skill still loads but no longer changes model
# behavior, e.g. after a model update). Runs via the local `claude` binary, so it
# spends Claude Code usage: ~400 calls at REPEAT=10.
#
# Results: benchmarks/results/<UTC date>/{principles,skills}.json (gitignored).
# Stamp:   benchmarks/results/.last-eval — UTC time of the last completed run (local only).
# Exit: 0 clean, 1 regression vs the previous run, 2 eval failure.
#
# Usage: scripts/weekly-eval.sh            # REPEAT=10 by default
#        REPEAT=5 scripts/weekly-eval.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
BENCH="$REPO/benchmarks"
RESULTS="$BENCH/results"
REPEAT="${REPEAT:-10}"
PROMPTFOO="promptfoo@0.124.1"
TODAY="$(date -u +%F)"
OUT="$RESULTS/$TODAY"

mkdir -p "$OUT"
previous="$(find "$RESULTS" -mindepth 1 -maxdepth 1 -type d ! -name "$TODAY" | sort | tail -1)"

status=0
for suite in principles skills; do
  config="promptfooconfig.yaml"
  [[ "$suite" == skills ]] && config="promptfooconfig-skills.yaml"
  echo "▶ $suite (repeat $REPEAT)"
  # promptfoo exits non-zero when any assertion fails; only a missing result file is an eval failure.
  ( cd "$BENCH" && npx -y "$PROMPTFOO" eval -c "$config" --repeat "$REPEAT" \
      --no-cache --no-progress-bar --no-write -o "$OUT/$suite.json" ) > "$OUT/$suite.log" 2>&1 || true
  [[ -s "$OUT/$suite.json" ]] || { echo "✗ $suite: no results (see $OUT/$suite.log)" >&2; exit 2; }

  node --experimental-strip-types "$BENCH/scripts/report.ts" calibrate "$OUT/$suite.json" | tee "$OUT/$suite.calibrate.txt"
  if [[ -n "$previous" && -s "$previous/$suite.json" ]]; then
    node --experimental-strip-types "$BENCH/scripts/report.ts" compare "$previous/$suite.json" "$OUT/$suite.json" \
      | tee "$OUT/$suite.compare.txt" || status=1
  fi
done

(( status == 0 )) && echo "✓ no regressions vs ${previous:-<first run>}" || echo "✗ regression vs $previous" >&2

# Local-only freshness stamp (results/ is gitignored); wk-sharpen proposes a run when it is >7 days old.
outcome="clean"
(( status == 0 )) || outcome="regression"
printf '%s status=%s results=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$outcome" "$OUT" > "$RESULTS/.last-eval"

exit "$status"
