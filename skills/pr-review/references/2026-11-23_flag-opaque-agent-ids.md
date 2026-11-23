---
class: principle
source: learnings/skills/pr-review/2026-11-23_flag-opaque-agent-ids.learned.md
date: 2026-11-23
skill: wk-pr-review
---

**Rule** — Flag every opaque, agent-generated identifier (code-like IDs, batch/round numbers, "rule N"/"shape N"
pointing at no list defined in the repo) that reaches a human-facing surface; post a `suggestion:` asking for a
readable reference or a legend.

**Why** — A PR's LLM check cited undocumented prefix-batch-number card IDs and internal numbering in its findings. The
review missed them until the user asked about the odd references and directed that these always be called out. The
skill had no readability lens for names produced by a generation or labeling pipeline.

**Where** — `SKILL.md` → Phase 4, severity/body bullets.
