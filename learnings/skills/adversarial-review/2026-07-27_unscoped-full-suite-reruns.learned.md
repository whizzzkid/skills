---
skill: wk-adversarial-review
date: 2026-07-27
type: correction
severity: high
verified-against-source: yes
---

Empirical-pass verification re-ran the full spec directory and 20 full-suite mutation cycles instead of scoping to the changed files, costing ~19 minutes on a small diff.

**What happened:** For a PR adding one new method plus wiring in two files, the empirical-pass step ran `bundle exec rspec` against the entire `check_health` spec directory (200 examples) multiple times, plus applied 20 individual code mutations each re-running the full directory to check for a killing test. CI already runs the full suite on the PR. The user explicitly stated the standing guidance — "only test the code that is affected" — had already been given and was not followed.

**Root cause:** The skill's empirical-pass HARD RULE says to "drive the real implementation... with adversarial/edge inputs and record PASS/FAIL" but does not instruct scoping the verification run to only the files/examples touched by the diff, so the natural default is a full-suite run per check.

**Suggested fix:** When driving an empirical pass or mutation test, run only the `describe`/`context` blocks or spec file(s) covering the changed method(s) (e.g. `bundle exec rspec spec/path/to/changed_spec.rb -e "prune_stale"`), not the full directory or full suite — CI is the source of truth for full-suite regressions, not the review's local verification pass.
