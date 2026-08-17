---
class: principle
---

# Choose isolation from the agent's tool needs, at dispatch time

**Rule** — Before dispatching, ask what the agent must *run*. Tests, lint, build,
commit, push, or PR creation → it needs shell → never `isolation: "worktree"`.
Shell unavoidable → skip isolation, or have the coordinator run the shell ops on
the worktree paths after agents finish editing.

**Why** — The constraint was already a HARD RULE and was still violated, with four
agents dispatched under isolation and all four needing manual recovery. The
reporting session said so outright: *the rule was already in the skill text at
dispatch time.* So volume was not the problem. The rule was phrased as a **fact
about isolation** ("isolated agents cannot run Bash"), which is read and agreed
with at read time, then not consulted at the moment isolation is chosen. Rewritten
as a **decision procedure keyed on the dispatch choice**, with the trigger in the
heading itself, so the rule is reached by the act it governs. There is also no
runtime error to catch the mistake — the agent simply cannot run the tool — so
dispatch time is the only cheap moment.

**Where** — `skills/workflow/SKILL.md` → the worktree-isolation HARD RULE.

## Escalation record

- Re-violation of a rule live since 2026-08-13 → this is rung **8**: restructure so
  the rule is structurally hard to skip. Chosen over a label bump because the
  section is already a `HARD RULE` heading, so there was no label headroom left and
  a louder fact would still be a fact rather than a decision.

## Byte ledger

Addition 140 B against 170 B headroom, funded by reclaiming 168 B: the pipe-verdict
rule was duplicated cross-skill, stated more completely in the shell workstyle skill
(which owns the `PIPESTATUS` zsh/bash split), so the inline copy became a pointer.
Net −28 B. Pointer-bearing lines in this file are already all under ~185 B from
earlier passes, so target-1 reclaims are exhausted here; cross-skill duplication is
where the remaining slack lives.

## Second lesson routed elsewhere

*Narrate rebase/push with before/after SHAs* went to the PR-update skill's final
report, not here — that skill owns rebase, patch-replay, and push, and had ~1.1 KB
of headroom against this file's 170 B. Placement followed ownership.
