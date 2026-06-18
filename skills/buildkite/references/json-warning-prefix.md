---
class: principle
---

**Rule:** Strip the auth warning before piping `bk ... --json` to `jq` — use `grep -v '^Warning:'`.

**Why:** Under env-var auth (`BUILDKITE_API_TOKEN`), `bk` prints `Warning: using BUILDKITE_API_TOKEN environment variable for authentication.` to stdout *before* the JSON payload, breaking `jq` with "Invalid numeric literal". `grep -v '^Warning:'` is safe whether or not the line is present; `tail -n +2` corrupts interactive-auth output (no warning line to drop).

**Where:** Canonical Build Query and every `--json | jq` pipe in the skill.
