---
class: principle
---

# Re-derive fix footprint when a deferred finding is reopened

**Rule** — When a reviewer/bot/user reopens a previously-deferred finding,
re-derive the fix footprint from scratch before re-deferring; the prior deferral
is voided, not settled. A finding is only "cross-cutting" if the fix touches a
shared interface or ≥2 call sites — and the deferral rationale must name them, or
it doesn't qualify. Otherwise it is localized → fix inline.

**Why** — A "cross-cutting / out of scope" rationale asserted without probing the
actual footprint becomes a default that survives a reopen unchallenged. Example:
a per-item loop query deferred as "query redesign beyond scope" actually collapses
to one grouped query over an identical range — one method, localized, should have
been fixed inline the moment the bot reopened it as a blocker.

**Where** — `wk-pr-resolve` Step 4 "Gate fix footprint".
