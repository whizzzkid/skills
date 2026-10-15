---
skill: wk-adversarial-review
date: 2026-10-14
type: pattern
severity: medium
verified-against-source: yes
---

A subagent "question" on code outside the diff, reproduced in a browser, surfaced a real pre-existing user-facing bug.

**What happened:** Reviewing an auth-tightening change, the fresh subagent flagged as a `question` (not run) that a
background poller on a public page pointed at a protected route. Driving it in a real browser with auth enabled and no
session confirmed it: after the first poll tick the frame swapped to "Content missing". It predated the PR, so it was
filed as a separate ticket rather than folded in. Other findings: an audit spec that checked class ancestry could not
detect a re-added skip guard, so it was documentation rather than enforcement; a test name overclaimed its starting
point; and a comment overgeneralized which routes were protected.

**Root cause:** Auth changes shift the anonymous/authenticated boundary for every background fetch on public pages, not
only for the edited route. Ancestry-based route audits pass any subclass, whatever its skip callbacks.

**Suggested fix:** For auth-boundary diffs, brief the subagent to list every background fetch (lazy frames, pollers,
streams) on public pages and check its target against the boundary. Reproduce such questions with a no-session browser
before closing them. Treat ancestry-only audits as a coverage gap to report.
