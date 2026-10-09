# Skill Eval Framework

Prevents skill atrophy by testing whether skills produce their intended behaviors.

## Architecture

Two-tier eval inspired by [ponytail](../agref/ponytail/):

```
benchmarks/
├── types.ts                    # Shared types (GraderResult, GraderContext, etc.)
├── tsconfig.json               # TS config (noEmit, strict)
├── promptfooconfig.yaml        # Full eval config (needs API key)
├── README.md
├── arms/
│   ├── baseline.ts             # Control: no skill, just the task
│   └── with-skills.ts          # Treatment: AGENTS.md + relevant skill as system prompt
├── graders/
│   ├── principles.ts           # 7 heuristic probes (imperative, ladder, minimal, etc.)
│   └── loc.ts                  # Code LOC counter (measurement, not gate)
└── tests/
    ├── principles.test.ts      # 19 unit tests for grader probes (no API key)
    └── loc.test.ts             # 6 unit tests for LOC counter
```

## Tier 1: Grader Tests (pre-commit)

Runs automatically via lefthook when any `SKILL.md` or `benchmarks/` file is staged.
No API key needed. Proves grader logic distinguishes good from bad output.

```bash
node --experimental-strip-types benchmarks/tests/principles.test.ts
node --experimental-strip-types benchmarks/tests/loc.test.ts
```

Requires Node ≥22.6.0 (`--experimental-strip-types`).

## Tier 2: Full Eval (manual)

Compares baseline (no skill) vs with-skills arms on a live model.
The delta measures whether skills produce their intended behaviors.

```bash
# Uses the local `claude` binary and your Claude Code login — no API key.
# EVAL_MODEL=claude-opus-5-5 to override the default model (claude-sonnet-4-6).
npx promptfoo@0.124.1 eval -c benchmarks/promptfooconfig.yaml --repeat 5
npx promptfoo@0.124.1 view
```

## Probes

| Probe | Tests | Pass signal |
|-------|-------|-------------|
| `imperative` | No hedging/pleasantries | Zero "you might want to" / "Sure!" |
| `ladder` | Prioritized options | "First try X, fall back to Y" |
| `minimal` | No over-engineering | No factory/abstract/extensible in code |
| `nevercut` | Security/validation present | Validation keywords in trust-boundary tasks |
| `boundary` | States scope limits | "Does not handle X" / "Risk: Y" |
| `concise` | Tight prose-to-code ratio | ≤15:1 ratio, ≤300 words for code tasks |
| `reuse` | Stdlib before deps | No `pip install` without stdlib mention |

## Adding a Probe

1. Add checker function to `graders/principles.ts` `CHECKS` map.
2. Add RED + GREEN test cases to `tests/principles.test.ts`.
3. Add a test row to `promptfooconfig.yaml` with `probe` and `task` vars.
4. Map probe → skill in `arms/with-skills.ts` `PROBE_SKILL`.

## ADR

See [Skill Eval Framework ADR](../docs/adr/skill-eval-framework.md).
