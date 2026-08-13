---
class: principle
skill: wk-workflow
date: 2026-07-09
---

- **Rule:** On a task `wk-plan` classifies complex (non-obvious architecture, an
  unresolved failure mode, or a high-blast-radius change), consult the `advisor`
  server tool during Phase 1 before committing to an approach, then fold its
  guidance into the plan. Reserve it for genuine uncertainty — skip trivial or
  single-step tasks. Consult *after* orienting on the problem and gathering
  context, never at turn 1 (a low-context call displaces a better-timed one).
  Proceed without it when the beta tool is not enabled in the session.
- **Why:** The advisor tool pairs a faster executor model (wk-workflow runs on
  Sonnet) with a higher-intelligence advisor model (e.g. Claude Opus 4.8) that
  reads the full transcript and returns strategic advice mid-generation — close
  to advisor-solo quality at executor rates. It is a weak fit for trivial or
  single-turn work where there is nothing to plan.
- **Setup (Anthropic API, beta):** add to the request `tools` array
  `{"type": "advisor_20260301", "name": "advisor", "model": "claude-opus-4-7"}`
  with beta header `advisor-tool-2026-03-01`. The executor decides when to call
  it; `tool_choice` can force a consult. The advisor model must be at least as
  capable as the executor. Docs:
  `https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool`.
- **Where:** Phase 1 (Plan) — added the complex-task advisor-consult bullet.
- **Scope note:** anchored to Phase 1 per the requester's "task classified
  complex" phrasing; widen to a mid-task consult at hard design forks (review
  blocker, design pivot) if desired.
