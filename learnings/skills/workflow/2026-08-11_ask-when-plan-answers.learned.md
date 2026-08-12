---
skill: wk-workflow
date: 2026-08-11
type: correction
severity: low
verified-against-source: no
---

Do not prompt the user for credentials/config when the project's plan doc or a
just-merged PR already specifies them.

**What happened:** Before validating a local OIDC roundtrip, the agent invoked
AskUserQuestion asking how to obtain real dev-realm credentials. The user
interrupted: those values were public and already documented in the merged
config PR the user had shared minutes earlier, and the plan's local-testing
section explicitly prescribed a dev-login shortcut that bypasses real
credentials entirely.

**Root cause:** (unverified — inferred from symptom) The agent treated "OIDC =
sensitive → must ask for secret" as an unconditional rule and skipped the
cheaper check: re-read the plan doc's local-testing guidance and the linked
config PR body before generating a question.

**Suggested fix:** Before firing AskUserQuestion for config/credential values,
re-scan (a) the project spec / plan docs and (b) any PR URL the user has
shared in the same session. Ask only if both are silent.
