---
skill: wk-pr-resolve
date: 2026-05-27
type: correction
severity: high
---

Step 8 "Update PR description" was skipped after push; user had to ask why CI statuses + new commits weren't reflected.

**What happened:** After pushing two new commits and posting/resolving threads in Step 8, the skill went straight to the (intended) `wk-retro` flow and skipped the "Update PR description" sub-step. The body still claimed `663 examples` and listed only the pre-resolve commit set; CI status section was absent entirely. The user noticed and asked why the description hadn't been updated.

**Root cause:** Step 8 in wk-pr-resolve.md lists the description-sync as a HARD RULE in prose form *between* the push step and the reply-posting step. In the actual execution flow, the agent treated the push → reply → resolve sequence as one block and forgot the body-sync at the end. The skill text says "After every push in this skill, sync the PR description" but does not include a structural gate (no checkpoint, no command template) that the agent executes mechanically. Combined with the recent learning that skipped the Step 7 confirmation prompt entirely, the agent flew past the body-sync without a natural pause point.

Compounding factor: the prior session's PR description was authored by `wk-pr` (not wk-pr-resolve), so the agent did not have a recent muscle-memory of editing the body during this skill.

**Suggested fix:** Move the body-sync to a numbered sub-step (e.g., Step 8.5: Sync PR description) immediately after the push, before any reply-posting. Make it a check-off the agent must explicitly satisfy with a `gh pr edit --body` call (or an explicit "no drift detected" log). Specifically include "CI status section" as an item the agent should check for and update — when the resolve session results in green CI, the body's status section needs to reflect that. The current skill text only says "correct any stale counts" which is too generic.

Additional: when the gate at the new Step 7 is skipped (per the previous learning), the body-sync at Step 8.5 becomes the *only* enforcement point for catching description drift. Make that explicit in the Step 7 skip path: "When skipping the Step 7 confirmation gate, Step 8.5 is non-negotiable — emit `gh pr edit --body` even if you believe the body is current."
