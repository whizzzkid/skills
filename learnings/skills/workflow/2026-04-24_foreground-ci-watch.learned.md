---
skill: wk:workflow
date: 2026-04-24
type: correction
severity: medium
---

CI watch invoked in the foreground blocks the rest of the workflow.

**What happened:** During the CI Fix Loop phase, I ran
`gh pr checks 66 --watch` as a foreground Bash call with a 5-minute
timeout. The user rejected the call. CI watching can block for many
minutes; foregrounding it stalls every other plan step (self-review,
docs audit, retro) for no reason.

**Root cause:** wk:workflow's Phase 6 (CI Fix Loop) describes "Poll CI
status" with `gh pr checks --watch` but does not specify the foreground
vs. background distinction. The natural reading is to call it directly,
which the Bash tool interprets as foreground.

**Suggested fix:** In Phase 6 Step 1, add an explicit instruction:

> Run CI watch as a backgrounded tool call (`run_in_background: true`).
> Continue with other plan steps — self-review preparation, docs audit
> — while CI runs. The runtime sends a completion notification when
> the watch exits. Only foreground a check when the next step
> genuinely depends on the result (e.g., right before `gh pr ready`).

This keeps the CI loop conceptually intact while letting independent
plan steps run in parallel.
