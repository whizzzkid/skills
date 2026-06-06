---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: high
---

Stage 0 interview prep scaffolding step silently skipped on two consecutive days.

**What happened:** The orchestrator read yesterday's evening.md (which listed a known interview), then launched the 5 parallel agents immediately. The Stage 0 step "Invoke `wk-cal §Interview Prep Scan` via the Skill tool before launching the parallel agents" was never executed. No prep block or scorecard block was created on the calendar for the Sid Mohalanobish Skills Assessment either day.

**Root cause:** The skill lists the interview prep scan as "scaffolding" in Stage 0, sandwiched between narrative text and the parallel-agent launch. The orchestrator rationalized skipping it because the interview was already "known" from evening.md carry-over data — treating the scan as redundant rather than as a required calendar-write step. The instruction does not have a hard-gate marker (unlike "HARD RULE"), making it easy to skip under time pressure or in auto mode.

**Suggested fix:** Elevate the interview prep scan to a **HARD RULE** with explicit skip-prevention language: "If any interview is present in today's or tomorrow's calendar events — including from evening.md carry-over — you MUST invoke `wk-cal §Interview Prep Scan` before launching Agent 3. Do not skip because the interview is already known. The scan creates calendar blocks; it does not merely read data." Add a post-scan verification: confirm at least one prep or scorecard block was created (or already existed) before proceeding to Stage 1.
