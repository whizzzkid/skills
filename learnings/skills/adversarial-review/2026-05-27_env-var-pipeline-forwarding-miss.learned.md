---
skill: wk-adversarial-review
date: 2026-05-27
type: gap
severity: high
---

Adversarial-review did not flag a new env var that the diff read in application code but the pipeline never forwarded into the container.

**What happened:** A PR introduced three new `ENV.fetch("FOO_*", ...)` reads in Ruby. The pipeline used `docker_compose` plugin steps whose `env:` array is an *allowlist* — Buildkite-agent-level env vars only enter the container when listed there. The diff added the vars to the agent's secret store but did not touch the pipeline template, so all three reads returned `nil` inside the container and the feature silently no-op'd at runtime. The build was green; the feature simply never fired. Operators only noticed because the expected side-effect (an APPROVE review) didn't appear.

`wk-adversarial-review`'s existing sweeps cover version pins, signature widening, sibling-script drift, comment accuracy, and cross-doc enumeration — but not "new ENV reads must be forwarded by every pipeline allowlist that runs the calling script".

**Root cause:** Multi-layer env forwarding is a class of bug where each layer in isolation looks correct: the env secret is set, the agent shows it in its environment dump, the Ruby code reads `ENV.fetch("FOO")` with a sensible default, and tests pass. The break is at the interface between the agent and the container — invisible unless the reviewer specifically walks both sides. The wk-buildkite skill already documents the four-layer pattern (pipeline `env:` / plugin `env:` / docker-compose `environment:` / Dockerfile `ENV`), but wk-adversarial-review doesn't sweep for it.

**Suggested fix (Step 2 mechanical sweep — new section "Env-var pipeline forwarding"):**

Run unconditionally on every diff that touches application code in a project that has a CI pipeline.

1. Extract new env reads from the diff (any language). Use a multi-language regex anchored to added lines:

   ```bash
   git diff "$BASE...HEAD" | grep -nE '^\+.*((ENV\.fetch\(|ENV\[)[ "''])([A-Z][A-Z0-9_]+)' \
     | grep -oE '[A-Z][A-Z0-9_]{3,}' | sort -u
   ```

   Cover Ruby (`ENV.fetch`, `ENV[...]`), Python (`os.environ`, `os.getenv`), JS/TS (`process.env.X`), Go (`os.Getenv`), shell (`${X}` after a recent `[ -z "${X:-}" ]` or new export).

2. For each var, find which entry-point script reads it (grep `bin/`, `cmd/`, `scripts/`).

3. For each entry-point script, find the pipeline template / CI step that invokes it (grep `.buildkite/`, `.github/workflows/`, `circleci/`, `azure-pipelines*`, `gitlab-ci*` for the script name).

4. For each invoking step, verify the var name appears in the step's env allowlist. The allowlist's name varies by platform:

   | Platform | Allowlist location |
   |---|---|
   | Buildkite + docker_compose plugin | `plugin :docker_compose, env: [...]` |
   | Buildkite native step | step `env:` block |
   | GitHub Actions | step or workflow `env:` block, or `secrets:` for reusable workflows |
   | docker-compose direct | `services.<svc>.environment:` |
   | Dockerfile (runtime default only) | `ENV` |

5. Flag a missing forwarding as a **blocker**. Symptom is invisible at build time and only surfaces when the feature is expected to fire — runtime null-read with default fallback.

6. Exemptions: env vars whose name matches the existing allowed-prefix pattern (e.g., Buildkite's `BUILDKITE_*` auto-injection) don't need explicit forwarding.

**Confidence:** high (mechanical regex + grep).

**Detection sketch (one-liner):**

```bash
for V in $(git diff "$BASE...HEAD" | grep -nE '^\+.*(ENV\.fetch|ENV\[|os\.environ|os\.getenv|process\.env\.)[ "''[\.]([A-Z][A-Z0-9_]+)' | grep -oE '[A-Z][A-Z0-9_]{3,}' | sort -u); do
  for SCRIPT in $(grep -rl "ENV.*$V\|os\.environ.*$V" bin/ scripts/ src/ lib/ 2>/dev/null); do
    grep -rl "$(basename $SCRIPT)" .buildkite/ .github/workflows/ 2>/dev/null | while read TEMPLATE; do
      grep -q "\"$V\"\b\|'\b$V'\b" "$TEMPLATE" || echo "BLOCKER: $V read by $SCRIPT but not forwarded in $TEMPLATE"
    done
  done
done
```

**Why this complements existing sweeps:** signature widening (2.7) catches code-to-code interface drift; this sweep catches code-to-pipeline interface drift. Both are "the caller doesn't pass what the callee expects"; the difference is the caller lives in YAML/DSL, not source.
