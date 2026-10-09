# Skill Eval Framework

Prevents skill atrophy by testing whether skills produce their intended behaviors.

## Architecture

Two-tier eval inspired by [ponytail](../agref/ponytail/):

```
benchmarks/
├── types.ts                    # Shared types (GraderResult, GraderContext, etc.)
├── tsconfig.json               # TS config (noEmit, strict)
├── promptfooconfig.yaml        # Principle eval (claude-cli provider, no API key)
├── promptfooconfig-skills.yaml # Skill-specific eval
├── README.md
├── arms/
│   ├── baseline.ts             # Control: no skill, just the task
│   └── with-skills.ts          # Treatment: AGENTS.md + vars.skill SKILL.md as system prompt
├── providers/
│   └── claude-cli.ts           # exec provider: isolated `claude -p`
├── graders/
│   ├── principles.ts           # Deterministic probes (imperative, nevercut, concise, reuse)
│   ├── skills.ts               # Skill-specific probes
│   └── loc.ts                  # Code LOC counter (measurement, not gate)
├── scripts/
│   └── report.ts               # calibrate / compare promptfoo results
└── tests/                      # Grader unit tests (no model calls)
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
npx promptfoo@0.124.1 eval -c benchmarks/promptfooconfig.yaml --repeat 10
npx promptfoo@0.124.1 view
```

The with-skills arm sends only the skill's `SKILL.md` as the system prompt — what an agent sees at
runtime. Set `EVAL_INCLUDE_AGENTS_MD=1` to prepend the repo's contributor `AGENTS.md`.

Compare skill versions with the same graders by pointing the with-skills arm at
another tree:

```bash
git archive <old-sha> skills AGENTS.md | tar -x -C /tmp/old-skills
SKILLS_ROOT=/tmp/old-skills npx promptfoo@0.124.1 eval -c benchmarks/promptfooconfig.yaml -o old.json
```

## Probes

| Probe | Skill (`vars.skill`) | Grader | Pass signal |
|-------|----------------------|--------|-------------|
| `imperative` | `concise` | regex | No hedges ("it depends", "you might want to") or pleasantries |
| `ladder` | `concise` | llm-rubric | One primary recommendation or an explicitly ordered fallback chain |
| `minimal` | `concise,workstyle-structure` | llm-rubric | No unrequested sources, frameworks, abstraction, or extension points |
| `nevercut` | `concise,workstyle-structure` | regex | guard: "Shortest" file route still contains the user path (resolve + base check, or `sendFile` `root`) |
| `boundary` | `concise` | llm-rubric | Ends with what was skipped/unchecked or a risk |
| `concise` | `concise` | regex | ≤120 prose words and ≤8 words per code line |
| `reuse` | `concise,workstyle-structure` | regex | HTTP JSON fetch uses `urllib` + `json`; no `requests`/`httpx` |

Calibrate after any probe change: a probe is valid only when the baseline arm passes ≤50% and the
with-skills arm ≥80% (`scripts/report.ts calibrate`). Guard probes (`kind: guard`) instead check the skill arm stays ≥80% on a default the bare model already gets right. Compare skill versions with
`scripts/report.ts compare old.json new.json`; drops within the baseline arm's run-to-run spread
(min 20pp) are noise, not regressions.

## Adding a Probe

1. Write a scenario the bare model tends to fail without the rule.
2. Grade it: a deterministic check in `graders/principles.ts` (with RED + GREEN cases in
   `tests/principles.test.ts`), or an `llm-rubric` assertion when the behavior is semantic.
3. Add the test to `promptfooconfig.yaml` with `probe`, `skill` (the skill whose text states
   the rule), and `task` vars.
4. Calibrate: `--repeat 10`, then `scripts/report.ts calibrate`. REDESIGN → fix the scenario
   (baseline passes) or the skill rule (skill arm fails) before relying on the probe.

## ADR

See [Skill Eval Framework ADR](../docs/adr/skill-eval-framework.md).
