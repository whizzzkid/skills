---
date: 2026-05-12
slug: scan-mode-interruptions
---

- **Rule:** `wk-learn scan` mines session transcripts under `~/.claude/projects/**/*.jsonl` for user interruption / redirect signals, classifies each by affected skill, and writes one learning file per finding.
- **Why:** Retro-based reflection misses moments the agent has already forgotten; evidence-driven capture surfaces patterns memory cannot.
- **Where:** New "Scan Mode" section after Step 4 in `wk-learn` SKILL.md; invoked automatically by `wk-retro` Step 1.5.
