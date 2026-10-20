---
class: principle
source: learnings/skills/sitrep/2026-10-20_truncated-agent-results.learned.md
date: 2026-10-20
skill: wk-sitrep
---

**Rule** — Give gathering agents an explicit output budget (one line per item, ~600 words) and treat a result that
ends mid-item as truncated. Re-request only the named missing sections, restating the cap.

**Why** — Agent result payloads are size-capped; a contract that only says "send results back" lets every agent
overflow it. A bare "send the rest" re-truncates; a compact, section-scoped resend fits.

**Where** — `references/subagent-contract.md` (contract bullet + orchestrator section); `SKILL.md` → start Stage 2
block handling.
