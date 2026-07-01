---
skill: wk-pr-resolve
date: 2026-07-01
type: correction
severity: medium
---

Under Auto Mode, presenting already-recommended bot findings for per-item
confirmation drew a user redirect to just make the call.

**What happened:** After re-review, three bot findings were surfaced each with a
clear recommended disposition (dismiss/dismiss/apply) plus a "confirm per-item or
batch?" prompt. The user replied that the agent was waiting on too many things
and should make these choices itself. The recommendations were already sound; the
confirmation step added no signal.

**Root cause:** Step 5's one-at-a-time consultation contract was applied to
findings that were effectively obvious-fix / already-decided, and Auto Mode's
"bias toward acting" was not weighed against the skill's default consult gate. A
stated recommendation the agent is confident in is itself the decision.

**Suggested fix:** In Auto Mode, when the agent has a clear recommendation for a
finding (especially bot findings with an empty or conceded skip rationale), act
on it directly and report the disposition, rather than pausing to confirm. Reserve
consultation for genuine judgment calls where a real tradeoff exists. Never batch
a "confirm all these?" prompt when the recommendations are already confident.
