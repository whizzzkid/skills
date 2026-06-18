---
skill: wk-adversarial-review
date: 2026-06-17
type: correction
severity: medium
---

Intentional env-var omission misread as a missing passthrough

**What happened:** An adversarial reviewer flagged a docker-compose `env:` array for not forwarding a variable (`CLOUDSMITH_REPO`), calling it a blocker. The omission was intentional — forwarding the var would have passed a wrong value injected by a plugin, overriding the script's correct default.

**Root cause:** The reviewer had no signal that the omission was deliberate. The only evidence was a spec that deleted the var and asserted the fallback behavior — invisible to code-only analysis.

**Suggested fix:** When reviewing env-var forwarding decisions, check whether a spec explicitly exercises the unset-var fallback path before flagging a missing passthrough as a blocker. A test that deletes the var and asserts the expected default is a strong signal of intentional omission. Downgrade to `question` rather than `blocker` when such a test exists.
