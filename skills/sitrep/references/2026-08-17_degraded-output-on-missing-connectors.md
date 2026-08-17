---
class: principle
---

# Evidence gaps degrade the artifact; they never truncate the run

**Rule** — Once every gathering fallback is exhausted and a domain is still
toolless, write the page anyway with each unavailable source labelled. Never
render partial output as complete. Preserve `data-done` state and carry-over,
drop stale dated meeting lines, keep the standup hierarchy, emit no unverified
outcome claim, and withhold accrual artifacts (rollover marker, brag log) until
full evidence can be reconciled.

**Why** — Treating a missing connector as a terminal hard block produced no
current page at all, while the alternative failure — synthesizing from the one
reachable domain — silently presented a partial day as a complete one. Both are
worse than an explicitly labelled degraded artifact. Withholding the rollover
marker is what makes the degradation self-correcting: the next `start` retries
the close instead of treating an evidence-poor day as closed.

**Where** — `SKILL.md` → *Core hard rules* (governs both sub-commands), with the
soft/hard block paragraph in `start` Stage 2 and the Quick Reference
service-auth row pointing at it.

## Report claims reconciled against source

- Claim "the skill lacked a degraded-output path" — **confirmed**. Per-domain
  degradation existed (stalled-agent nudge ceiling, `tool_unavailable` →
  main-context replay), but nothing covered the replay *itself* being toolless,
  and the installed text classified a missing MCP as a plain hard block.
- Suggested remedy "user-authorized degraded-output path" — **re-expressed**.
  The skill's *no interactive triage* HARD RULE forbids prompting, so the
  degraded write is authorized by the invocation itself; the rule was placed
  adjacent to that HARD RULE rather than restating a no-prompt clause. Do not
  re-propose a confirmation prompt for this branch.
- Suggested scoping to "direct rerun requests" — **widened**. The withheld
  artifacts (rollover marker, brag log) belong to `end`, so the rule is
  top-level and binds both sub-commands, not just a rerun of `start`.
