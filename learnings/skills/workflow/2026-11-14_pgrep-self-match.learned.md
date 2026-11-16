---
skill: wk-workflow
date: 2026-11-14
type: surprise
severity: low
verified-against-source: no
---

A wait loop of `until ! pgrep -f "<cmd>"` never exits because pgrep matches the wrapper shell whose command line contains the same pattern.

**What happened:** Two background waiters for a test run stayed armed until timeout even though the run had finished.

**Root cause:** (unverified — inferred from symptom) `pgrep -f` matches the full command line of the waiting shell itself, which embeds the pattern.

**Suggested fix:** Wait on the background task completion notification instead, or bracket the pattern (`[b]uild.sh`) so it cannot match itself.
