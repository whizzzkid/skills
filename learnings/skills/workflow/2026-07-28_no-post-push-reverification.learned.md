---
skill: wk-workflow
date: 2026-07-28
type: correction
severity: medium
verified-against-source: yes
---

Never re-run local build/test commands after a push whose CI already runs them.

**What happened:** After pushing, the full local verification suite (build, token-drift
check, e2e smoke) was re-run for confirmation. The same commands had already passed via the
pre-push hook and were re-running in CI against the same SHA. The user called this out twice,
the second time as pure token waste.

**Root cause:** Verification was treated as reassurance rather than as evidence-gathering.
A command whose result is already known adds no information; re-running it reads as progress
while producing none.

**Suggested fix:** State the rule explicitly in the verification guidance:

- Local verification runs **before** the push, once, as the gate.
- After the push, the evidence is the pre-push hook's exit status plus the CI run on that
  SHA. Poll CI; do not re-execute the same commands locally.
- Re-run locally only when something changed (a new commit) or when a CI failure needs to be
  reproduced.
- More generally: before running any command, name what new information its result would
  provide. If the answer is already known, skip it.
