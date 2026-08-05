---
class: principle
---

# Contradictory runtime state requires a forced-stop restart

**Rule** — When `colima start` reports an already-running VM but `colima
status` or `docker info` disagrees, treat runtime state as stale and use the
full forced-stop restart sequence. Retrying start preserves stale PID or socket
state.

**Classification** — `already-covered` re-violation. Before this report,
Step 3 routed failed Docker verification to Step 4, while Step 4 routed failed
starts to the same forced-stop sequence. The fresh repeat escalates that rule
from baseline prose to `**Important:**` and names the contradictory-state
symptom explicitly.

**Where** — `SKILL.md` → Step 3, immediately after Docker verification.
