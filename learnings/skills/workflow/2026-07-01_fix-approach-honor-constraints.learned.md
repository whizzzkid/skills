---
skill: wk-workflow
date: 2026-07-01
type: correction
severity: medium
---

When a symptom has multiple valid fixes, confirm the intended fix philosophy before drafting one — the obvious fix may violate an unstated constraint.

**What happened:** Diagnosing a Kafka-library log-error spike (management-UI topics not provisioned because prod disables auto topic creation), the agent's first-draft fix proposed provisioning those topics (a migrate step) or producing to them. The user redirected: listen-only — never create topics, never produce. The whole technical approach had to be reshaped to *disabling* the library's producing/commanding subsystems instead.

**Root cause:** The agent optimized for "make the feature work" (provision the missing topics) rather than asking whether producing/creating was even acceptable in this app's role. The app is a pure consumer; that constraint was discoverable but not confirmed up front.

**Suggested fix:** In Phase 1 planning, when the fix space includes both "add/produce/provision" and "disable/suppress" branches, surface the branch choice as an explicit plan decision (or one-line question) before implementing — especially for infra whose role (consumer-only vs producer) constrains which branch is legal.
