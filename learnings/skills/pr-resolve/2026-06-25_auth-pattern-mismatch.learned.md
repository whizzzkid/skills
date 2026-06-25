---
skill: wk-pr-resolve
date: 2026-06-25
type: correction
severity: medium
---

Verify auth-pattern applicability before adopting middleware pattern.

**What happened:** When applying a {bot} finding, the agent added `require_auth` calls to download functions after observing that other {service} scripts in the codebase use the pattern. The user corrected this mid-flow: the pattern applies to gated operations (AWS SSO where `NO_AUTH` is a valid runtime state), but the {tool} download fetches a public binary via a CLI that manages its own credentials — no require_auth needed.

**Root cause:** Pattern reuse without re-reading the scenario. The agent saw "cloudsmith" + precedent examples and applied the pattern locally without verifying the auth model matched (gated operation vs. CLI-managed credentials).

**Suggested fix:** When a {bot} finding suggests a pattern already used elsewhere in the codebase, verify the scenario matches before copying: guard against "pattern exists, therefore this context needs it" logic. A second opinion or design review step early would have surfaced the mismatch.
