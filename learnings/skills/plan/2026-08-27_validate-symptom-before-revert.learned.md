---
skill: wk-plan
date: 2026-08-27
type: pattern
severity: medium
verified-against-source: yes
---

Validating a reported symptom against the reference checkout before planning a fix prevented an unnecessary revert + rewrite.

**What happened:** After merging a PR that added an idempotent re-POST, the user reported the re-POST was "deleting" records in the downstream app and moved to revert and re-implement the emission as a PATCH. Running the is-a-fix-warranted gate first — reading the ingest path and dispatching a read-only sweep of the downstream app — proved no deletion path existed (all associations `restrict_with_exception`; replay specs assert the re-POST is a no-op). The user then confirmed the observation was a UI perception issue: data was slow to load and the app has no skeleton loaders, so the record looked deleted.

**Root cause:** A perceived-data-loss report is indistinguishable from a real one at the prompt level; without the validation gate the plan would have executed a revert and a cross-repo re-implementation of a correct design.

**Suggested fix:** Reinforce the is-a-fix-warranted gate: when a symptom report drives a revert/rewrite of freshly-merged work, validate the mechanism in the affected system first and surface "no fix needed" as an explicit option. When a PR was already reverted on a premise that dissolves, plan a re-land of the original commit, not a re-implementation. Also surface UI-affordance gaps (e.g. missing skeleton loaders) as the real follow-up when perception, not data, was the defect.
