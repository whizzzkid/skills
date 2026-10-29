---
skill: wk-pr-takeover
date: 2026-10-29
type: correction
severity: high
verified-against-source: yes
---

A dependency-bump PR's "canceled" CI build was a real regression, not infra flake.

**What happened:** A grouped dependency bump showed a canceled review build on every push. Reading the canceled job's
log showed a fail-closed gate tripping: a JSON library major bump (2.x -> 3.x) now raises on non-ASCII strings tagged
ASCII-8BIT, which a tar reader yields. Every PR with an emoji in its diff would have been blocked.

**Root cause:** The skill does not tell the agent to triage canceled or self-cancelled jobs by log before treating
them as infra noise. A gate that cancels the build on failure looks like a flake on the checks summary.

**Suggested fix:** In Step 4 / CI triage, read the log of any canceled job that cancelled the build, and for dependency
bumps, audit major-version transitive bumps in the lockfile (not just the Gemfile/package manifest) for behavior
changes. A linter bump with `NewCops: enable` will also produce mass offenses: autocorrect, then review "unsafe"
corrections and any touched fixture/corpus files individually.
