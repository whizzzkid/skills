---
class: one-off
skill: wk-renovate
date: 2026-11-27
severity: low
---

# Scoped resolve overshoot — already covered

**Verdict** — `already-covered`: Step 3 HARD RULE sub-bullet "Pin each named package to its exact advertised version;
a scoped update resolves to the newest release and overshoots Dependabot's target" and the loop's "then pin each to
its advertised version" (installed 2026-11-20, before the report).

**No escalation** — same-session evidence the rule fired: every overshoot was caught in the diff, pinned back, and
validated with install before commit.
