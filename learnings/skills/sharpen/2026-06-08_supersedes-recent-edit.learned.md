---
skill: wk-sharpen
date: 2026-06-08
type: pattern
severity: medium
---

A new high-severity learning can supersede a rule added earlier the same session — reconcile, don't stack.

**What happened:** A high-severity learning said production had abandoned the markdown-table dashboard format for an HTML div layout. The target skill had a "render as one 3-column table" HARD RULE added only hours earlier in the same session. Folding the new learning required reversing the prior edit across the format rule, write templates, and the done/pending detection — plus delegating layout mechanics to a newly-created sibling skill — not adding a second, contradictory rule.

**Root cause:** The audit step (Step 5 "contradictory rules") assumes contradictions come from old, stale prose. It does not flag that the freshest edits — including ones from the current run — are the most likely to be reversed by a newer learning, because format/approach churn lands as a cohort of same-day learnings.

**Suggested fix:** In Step 5's contradiction audit, explicitly check the current run's own edits and the most recent `.distilled-sources.log` entries for the target skill against each new learning. When a higher-severity or newer learning reverses a recent edit, replace/reconcile the prior rule and record the supersession in the new reference file's `Supersedes:` line — never leave both rules live. Also: when a learning's mechanism is large enough to be its own domain, extract it to a sibling skill and have the consuming skill delegate, rather than duplicating the mechanics inline.
