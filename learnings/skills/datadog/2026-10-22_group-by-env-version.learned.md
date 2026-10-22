---
skill: wk-datadog
date: 2026-10-22
type: correction
severity: high
verified-against-source: yes
---

Log counts for a multi-env, multi-version service must be grouped by `env` and `version` before any causal claim.

**What happened:** A latency investigation compared two log lines of a webhook-ingest service ("enqueued" vs
"published") with ungrouped `logs aggregate` queries. The two numbers matched per minute, which supported the
conclusion "events were received late, not held in the queue". That conclusion was posted to the ticket. An
adversarial pass then found three problems:
- The "enqueued" series came from the staging deployment. Staging mirrors production traffic, so it shows
  production-like volume.
- The "published" series came from production.
- Different production versions deployed that day each emitted only one of the two lines, never both.

Once the counts were grouped by `env` and `version`, the conclusion reversed. Production had accepted the events on
time and published them late.

**Root cause:** The skill has no rule to split counts by deployment dimensions before comparing log lines. An empty
or matching series reads as signal when it is really an env or version artifact.

**Suggested fix:** Add a HARD RULE to wk-datadog:
- Before comparing counts of two log lines (or one line across time) for a service, run the same aggregate with
  `--group-by=env,version`.
- If one line exists only in some versions or envs, say so, and do not infer flow or latency from the ratio.
- Run an adversarial or independent check on causal findings before posting them to an external tracker.
