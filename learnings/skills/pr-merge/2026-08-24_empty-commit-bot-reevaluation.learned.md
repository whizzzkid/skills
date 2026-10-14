---
skill: wk-pr-merge
date: 2026-08-24
type: gap
severity: medium
verified-against-source: no
---

Document empty-commit trick for bots that post COMMENTED instead of APPROVED

**What happened:** After resolving all reviewer threads, a bot's review status remained COMMENTED (not APPROVED), blocking merge. An empty commit triggered the bot to re-evaluate and post an APPROVED review. This was discovered by trial and error.

**Root cause:** (unverified — inferred from symptom) Some review bots only re-evaluate on new pushes, not on thread resolution events. Their initial review posts as COMMENTED and never upgrades to APPROVED without a new commit triggering re-evaluation.

**Suggested fix:** Add a step to the merge-readiness check: when a bot review is COMMENTED (not APPROVED) after all threads are resolved, push an empty commit (`git commit --allow-empty -m "chore: trigger bot re-evaluation"`) to prompt the bot to re-assess.
