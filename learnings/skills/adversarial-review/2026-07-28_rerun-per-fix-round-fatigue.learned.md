---
skill: wk-adversarial-review
date: 2026-07-28
type: correction
severity: high
verified-against-source: n/a
---

Re-invoking the full review on every fix round exhausted {user}, who explicitly waived the gate to force the merge through.

**What happened:** Across one long feature session the skill was entered repeatedly — once per push and again after each round of blocker fixes — including a final full re-review (mechanical sweeps plus a fresh subagent) that had already been cleared in substance by the earlier passes. {user} interrupted mid-dispatch, said the repeated reviews were driving them insane, and instructed the agent to skip straight to merge.

**Root cause:** The contract mandates a run before every push, force-push, and ready transition, and treats each fix round as a new push, so a session with N fix rounds pays N full reviews. Contract #3's "fix residuals in ≤1 follow-up → re-review" caps re-review at one round, but nothing in the skill counts invocations per session or tells the caller to batch several fix commits into a single re-review — so the per-push rule silently wins and the cap is never reached.

**Suggested fix:** Add an explicit per-session budget to the contract: after the first clear-or-blocked verdict, batch all remaining fixes into ONE re-review scoped to `git diff <cleared-sha>..HEAD`, and state that intermediate pushes within a fix loop do not each earn their own full run. Make the skill announce which invocation number it is on so the cost is visible, and treat a user's fatigue signal as an immediate hard waiver — never re-dispatch after it, in this or any later step of the same session.
