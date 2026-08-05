---
skill: wk-colima
date: 2026-08-05
type: pattern
severity: medium
verified-against-source: yes
---

Treat contradictory status after startup as stale VM state.

**What happened:** A start command reported that the VM was already running, but both the status command and Docker
connectivity immediately showed that it was stopped.

**Root cause:** The VM manager retained stale runtime state after an incomplete shutdown. A forced stop removed stale
PID and socket files, after which a normal start restored Docker connectivity.

**Suggested fix:** When startup says "already running" but status or Docker connectivity disagrees, run the skill's
full forced-stop restart sequence instead of retrying start in place.
