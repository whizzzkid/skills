---
skill: wk-workflow
date: 2026-08-01
type: correction
severity: high
verified-against-source: yes
---

Default-branch-only generators require acceptance tests against their exact downstream artifacts before the feature is complete.

**What happened:** Release automation passed feature-branch CI because its tests asserted configuration strings while UI snapshots exercised only bootstrap metadata; the first real generated candidate later failed both formatting and visual gates.

**Root cause:** The completion gate accepted an explicit "cannot run until the default branch" caveat and future-tense rollout verification for a producer whose generated files and mutable metadata were consumed by repository CI, so neither the generated changelog nor a representative calendar version reached those consumers before merge.

**Suggested fix:** Add a wk-workflow gate for default-branch-only producers: invoke the pinned generator in an isolated repository or use a controlled live canary, feed its exact output through every downstream required check, and keep the deliverable incomplete until the first live generated artifact also passes its own required CI; a documented post-merge execution limitation is a blocker, not a waiver.
