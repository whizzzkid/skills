---
class: principle
source: learnings/skills/adversarial-review/2026-11-20_verify-brief-env-claims.learned.md
date: 2026-11-20
skill: wk-adversarial-review
---

**Rule** — Prove every environment claim in a reviewer brief (installed versions, present sources, fixtures, services)
with a command before dispatch; state the fetch command for anything missing.

**Why** — A brief said both old and new dependency versions were installed for source diffs; several old versions were
absent. Reviewers noticed and fetched them, costing time. The claim rested on an assumption that a container
provisioned from the base lockfile keeps every old package after the update, never checked with `ls`.

**Classification** — `principle`, new rule (no installed rule covered brief-content verification; the diff-transcription
rule covers only the diff payload).

**Where** — `SKILL.md` → Step 3 (Fresh Adversarial Subagent), "Brief only verified environment facts"; README.
