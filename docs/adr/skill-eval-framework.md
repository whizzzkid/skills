# Skill Eval Framework

**Status:** Accepted
**Date:** 2026-10-08

## Context

Skills accrete bloat across sharpening passes. Without automated evaluation,
skills can silently atrophy — they still load, but the model no longer produces
the intended behaviors. The `check-skill-size.sh` hook catches structural bloat
(byte ceilings), but not behavioral drift.

Ponytail (agref/ponytail) demonstrated an effective pattern: **promptfoo-based
evals with heuristic graders**, where:

1. Graders are deterministic JS/TS functions that detect behavioral signals in
   model output (e.g., "uses imperative voice", "presents decision ladder").
2. Grader logic is proven by unit tests that need no API key (RED/GREEN locally).
3. Full evals run the same graders against live model output via promptfoo, comparing
   a baseline (no skill) arm against a with-skills arm.
4. The delta between arms measures whether skills produce their intended behaviors.

## Decision

Adopt a two-tier eval framework for wk-skills:

### Tier 1: Grader unit tests (pre-commit + pre-push)

- **What:** `node:test` suites in `benchmarks/tests/` exercise each grader probe
  against known-good and known-bad outputs.
- **When:** Every commit/push that touches `SKILL.md` or `benchmarks/` files.
- **How:** `check-skill-principles.sh` lefthook gate. Requires Node ≥22.6.0 for
  `--experimental-strip-types` (TS without build step).
- **Cost:** Zero — no API calls, runs in <100ms.
- **Catches:** Grader regressions (a refactor breaks the checker itself).

### Tier 2: Full promptfoo eval (manual / CI)

- **What:** `npx promptfoo@0.124.1 eval -c benchmarks/promptfooconfig.yaml`
  runs each probe task through baseline and with-skills arms on a live model.
- **When:** Before debloat passes, after major skill rewrites, weekly cron.
- **How:** Shells out to `claude -p` (isolated: no settings, tools, skills, MCP) via `benchmarks/providers/claude-cli.ts`, reusing the Claude Code login — no API key. Reports principle pass rates and LOC
  metrics per arm.
- **Cost:** ~7 API calls × 2 arms × N repeats. At `--repeat 5`: ~70 calls.
- **Catches:** Behavioral atrophy (skill still loads but model ignores it).

### Probes

Each probe tests one cross-cutting principle:

| Probe | Principle | Signal |
|-------|-----------|--------|
| `imperative` | Imperative voice, no hedging | Zero hedge/pleasantry instances |
| `ladder` | Prioritized decision ladder | "First try X, fall back to Y" |
| `minimal` | Smallest change, no over-engineering | No factory/abstract/extensible patterns |
| `nevercut` | Never cut validation/security | Validation keywords present |
| `boundary` | Boundary statements | States what's out of scope |
| `concise` | Prose doesn't dwarf code | ≤15:1 prose-to-code ratio, ≤300 words |
| `reuse` | Stdlib before new deps | No `pip install` without stdlib mention |

### Language

TypeScript with Node's `--experimental-strip-types`. No build step, no bundler,
no `tsx`/`ts-node` dependency. Types checked via `tsc --noEmit` against
`benchmarks/tsconfig.json`.

## Consequences

- Every skill change runs grader tests — catches grader regressions immediately.
- Full evals catch behavioral drift before debloat passes (run before → after).
- Adding a new principle = add a probe to `graders/principles.ts` + test cases +
  a promptfoo test row. ~30 lines per probe.
- Node ≥22.6.0 requirement for the pre-commit hook (graceful skip on older).

## Alternatives Considered

1. **LLM-as-judge per commit** — too slow and expensive for pre-commit.
2. **Static linting only (regex on SKILL.md)** — catches bloat but not behavioral drift.
3. **JavaScript without types** — ponytail's approach; we chose TS for
   maintainability since our grader set will grow larger.
