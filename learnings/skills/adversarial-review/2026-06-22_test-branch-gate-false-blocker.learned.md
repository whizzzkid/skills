---
skill: wk-adversarial-review
date: 2026-06-22
type: correction
severity: medium
---

Test-branch intentional gate removal flagged as blocker by adversarial subagent

**What happened:** A branch whose entire purpose was to remove a CI gate (`if main_build?`) so a specific step would run on CI for validation got that removal flagged as a `blocker` by the adversarial subagent ("live side-effecting step guarded only by a comment"). The change was intentional, documented in the PR title ("DO NOT MERGE"), body, and inline comment — not an oversight.

**Root cause:** The adversarial subagent has no context about the PR's stated purpose. Without that context, a gate removal that exposes a live side-effecting step looks like a security/data-loss risk, which is the correct call in isolation. The skill currently does not prompt the subagent to distinguish "intentional throwaway test branch" design from "accidental gate removal regression."

**Suggested fix:** Before dispatching the adversarial subagent, feed it the PR title and body as context — specifically the "purpose" section. Instruct it: "If the PR description explicitly documents a change as intentional, test-only, or throwaway, treat that as stated context before classifying it as a blocker." This prevents false blockers on test branches while preserving the guard on production branches where the same pattern would be genuinely risky.
