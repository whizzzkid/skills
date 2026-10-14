---
class: principle
---

# The review body is the verdict phrase plus the footer

**Rule**

- Body = `LGTM 🚀` / `LGTM, one minor nit` / `Approving with concerns`, then the footer.
- No `— <biggest risk>` suffix, no pointer to the key thread, no praise line. Inline comments already carry that
  content, and GitHub shows them under the review.
- Extra prose only for a change-wide concern with no inline anchor, one sentence.

**Why**

- The user cut a three-clause body (risk suffix, thread pointer, approval sentence) to the bare verdict before
  submitting. Every clause they cut was explicitly allowed by the skill's own template, so the agent treated the
  allowances as defaults. Earlier body-verbosity folds tightened prose but never removed those allowances, so the
  problem kept recurring.

**Escalation**

- Corrected the template (wrong instruction), and merged the opener and one-line rules into one HARD RULE that
  applies with or without concerns. The re-violated meta-commentary ban became a HARD RULE pre-POST sentence gate
  (structural rung). The 2026-07-17 opener and no-restate references are marked superseded.

**Where**

`skills/pr-review/SKILL.md` → Phase 5 body HARD RULE; Phase 4 praise routing (generic praise → omit, not body).
