---
skill: wk-pr-resolve
date: 2026-07-21
type: correction
severity: medium
---

A finding deferred as "cross-cutting / out of scope" was actually a localized fix; the deferral should have been re-evaluated the moment it was reopened, not rubber-stamped.

**What happened:** A bot flagged an N+1 query in round 1; it was deferred to PR-body Follow-ups as "cross-cutting query redesign beyond this PR's scope." On the post-push re-review the bot reopened it as a blocking finding. On inspection the fix was contained to one method (a per-item loop query collapsed to a single grouped query, since the range was identical across items) — not cross-cutting at all. The user also had to prompt to finish the remaining sibling N+1.

**Root cause:** The original deferral rationale ("cross-cutting") was asserted without probing the actual fix footprint. Once written into Follow-ups it became a default that survived a reopen unchallenged.

**Suggested fix:** When a previously-deferred finding is reopened by a reviewer/bot/user, re-derive the fix footprint from scratch before re-deferring — do not treat the prior deferral as settled. A finding is only truly "cross-cutting" if the fix touches a shared interface or multiple call sites; a per-item query that collapses to one grouped query over an identical range is localized and should be fixed inline, not deferred. Deferral rationale must name the specific shared interface / call sites that make it cross-cutting, or it doesn't qualify.
