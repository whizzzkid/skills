---
skill: wk-pr-review
date: 2026-05-29
type: pattern
severity: high
---

For skill-doc PRs, cross-reference every allowlist/rule claim against the cited live validator.

**What happened:** A doc-only diff added a new agent skill whose primary recommendation (`cargo fetch`) was not in the actual runtime validator's allowlist on the current branch — it was added by a companion PR that was still open. The skill body linked the validator file as "source of truth if anything here drifts," making it straightforward to check. Reading the validator caught the drift; the PR body disclosed the dependency but SKILL.md itself (the artifact users actually invoke) did not.

**Root cause:** Doc-only escape hatch in Phase 4 substitutes read-based analysis but doesn't explicitly call out "verify every claim in the skill against the files it cites as authoritative." The check only ran because the cited validator was a direct linked path in RELATED — easy to follow, but not mandated by the skill flow.

**Suggested fix:** Add a step to the documentation-only Phase 4 analysis: for skill docs that cite a live code file as the source of truth (the pattern "see {path} — authoritative if anything here drifts"), read that file and audit every constraint the skill doc states (allowlists, char classes, field names) against the live code. A skill doc that misstates an allowlist entry ships broken configs at user invocation time.
