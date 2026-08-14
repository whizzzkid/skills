---
skill: wk-workflow
date: 2026-08-14
type: gap
severity: medium
verified-against-source: n/a
---

Follow through on every explicit user request, even if it feels tangential

**What happened:** User explicitly asked agent to "create a follow up PR to run rubocop pre-push" as a reliability improvement. Agent acknowledged the request but never created the PR or even tracked it as a follow-up item. The request was dropped silently.

**Root cause:** Agent treated the user's request as venting/frustration commentary rather than an actionable task. No mechanism in the workflow forces tracking of mid-session user requests that aren't part of the current PR's scope.

**Suggested fix:** When a user makes an explicit request during a session (especially one framed as "you need to do X"), immediately either (a) act on it, or (b) surface it as a tracked follow-up item that gets reported at session end. Never silently drop an explicit ask.
