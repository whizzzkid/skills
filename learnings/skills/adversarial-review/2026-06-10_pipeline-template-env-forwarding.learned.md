---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: high
---

Sweep 2.20 (env-var forwarding) must check the sibling pipeline step template, not just the app code.

**What happened:** A new pipeline step template was created that invoked an entry-point script with Buildkite env-var fallbacks (`BUILDKITE_REPO`, `BUILDKITE_PULL_REQUEST`). The env-var forwarding sweep found the reads in the app code but did not cross-check the new template's docker-compose `env:` list. Both fallback vars were absent from the template, making them dead inside the container.

**Root cause:** Sweep 2.20 greps app code for new `ENV.fetch`/`ENV[...]` reads and traces to the pipeline template that invokes the script, but it traces by script name to *existing* templates — it does not scan *newly-added* templates for vars the script already reads via fallbacks.

**Suggested fix:** After building the new-env-var set from the diff, also extract every Buildkite-native env var that the script reads (including fallbacks already in the diff baseline), then check those vars against the new template's docker-compose `env:` list. Flag any Buildkite-native var (BUILDKITE_*) read by the script but absent from a newly-added template as a blocker.
