---
skill: wk-buildkite
date: 2026-06-23
type: gap
severity: medium
---

When starting background CI monitoring after a push, the agent must immediately report the build URL and what failure it is watching for — not just "monitoring in background."

**What happened:** After a push, the agent said "Pushed. Monitoring CI build #N in the background." without stating the build URL, the failing step, or what diagnostic action was being taken. The user had to interrupt with "The CI is failing, what are you checking?" to get a status update.

**Root cause:** The monitoring announcement was too terse — it omitted the build URL, the current failing step name, and the agent's next planned action (e.g., "fetching logs for the RuboCop step"). The user could not determine whether the agent had already identified the failure or was still discovering it.

**Suggested fix:** After any `git push`, report: (1) the build URL from `bk build view --json | jq .web_url`, (2) the current failing step (if already known), and (3) what the agent will do next. Example: "Build #N running — {URL}. Watching for failures in the RuboCop and spec steps."
