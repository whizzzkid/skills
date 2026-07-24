---
skill: wk-sharpen
date: 2026-07-24
type: pattern
severity: medium
---

Reproducing a reported hook misfire beat the report's own root-cause hypothesis —
and its suggested fix would have weakened a security guard.

**What happened:** A learning reported a scope-guard hook blocking legitimate
recursive searches, hypothesizing the cause as "the guard derives the repo root from
the session's starting directory" and suggesting the guard honor a task-provided root
instead. Mid-distillation the same guard blocked one of this run's own commands, and
the block message named the out-of-scope path as the repo root *plus a trailing
semicolon* — from a `cd <root>;` command prefix. Reading the owning script confirmed
a different defect: the token loop stripped surrounding quotes but not trailing shell
separators, so an in-scope absolute path compared as outside. That is a token-hygiene
bug fixable in one line, and stripping the separator sharpens the comparison in both
directions rather than loosening it. Folding the report's suggested fix instead would
have made the guard accept an agent-supplied root — materially weaker, and destroying
the property that makes a hook un-rationalizable.

**Root cause:** The skill's Step 1/Step 2 treat the report as the authority on root
cause: read the incident, extract "root cause", then read the target skill. Nothing
directs the agent to verify the reported mechanism against the owning source, or to
try reproducing it, before drafting. For a learning about a deterministic artifact
(hook, script, CI check) the ground truth is cheaply readable and often contradicts a
field report's inference — the reporter observed a symptom and guessed a cause.

**Suggested fix:** In Step 1 or Step 3, require that a learning about a
deterministic artifact have its reported mechanism confirmed against that artifact's
source before drafting — read the script and, where cheap, reproduce the failure.
Treat the report's "Root cause" as a hypothesis and its "Suggested fix" as
non-authoritative. Add an explicit gate: when a proposed fold would *relax* a
guard/check, reject it and look for the correctness bug instead — a guard that
accepts a caller-supplied scope is weaker than one deriving scope from the
environment. Record the rejected suggestion and the rationale in the reference file
so it is not re-proposed.
