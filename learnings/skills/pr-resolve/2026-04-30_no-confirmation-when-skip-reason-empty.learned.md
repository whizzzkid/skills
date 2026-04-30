---
skill: wk:pr-resolve
date: 2026-04-30
type: correction
severity: medium
---

If "Why this could be skipped" reduces to "no valid reason," the comment is `obvious-fix` — auto-apply, do not consult.

**What happened:** During a `wk:pr-resolve` session on PR #NNN, the agent classified a bot finding ("domain logic in `GithubClient`") as `judgment-required` and asked for `(a/e/d/s)` confirmation, even though the agent's own "Why this could be skipped" rationale was *"No valid reason — the design regressed when I added this method without restoring the domain-layer filtering pattern."* The user pushed back: "when there was no obvious reason to skip the fix, then why did you ask me if you can fix it."

**Root cause:** The agent treated the word "design" / "refactor" as a reflex trigger for `judgment-required`, overriding the actual classification rule. Step 4's table is explicit: `obvious-fix` ⇔ "Why this could be skipped" reduces to "no valid reason / empty / broken link / stale reference." A design change can absolutely be obvious if there is no real tradeoff and the agent cannot honestly produce a reason to leave the code as-is. The category isn't "is this a structural change?" — it's "is there a real tradeoff between applying and not applying?"

**Suggested fix:** Add a hard check to Step 4 classification:

> Before tagging a comment `judgment-required`, re-read your own "Why this could be skipped" rationale. If it contains any of: "no valid reason," "no good reason to skip," "empty," "—," or any phrasing that effectively concedes the bot is right and there is nothing to weigh — the tag is **`obvious-fix`**, regardless of whether the change is mechanical, design-level, refactor-shaped, or touches multiple files. The classification key is the **skip rationale**, not the **change shape**.

Also add to Step 5's consultation prompt: if the agent finds itself drafting "(d) Dismiss" with reason field empty or "no valid reason," that is a signal the prompt should never have been emitted — re-classify and move the comment to the auto-apply queue before sending the message.

A reasonable second-pass heuristic: if the agent would not push back on the bot's finding *if it were doing the review itself*, it's `obvious-fix`. If the agent has a meaningful counterargument worth presenting, it's `judgment-required`.
