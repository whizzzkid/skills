---
skill: wk-datadog
date: 2026-10-14
type: surprise
severity: high
verified-against-source: yes
---

Query a code-emitted metric only after listing its real name; an unprefixed query returns an empty series, not an error.

**What happened:** A query for the metric name exactly as written in app code returned `series: []`, which nearly
became the conclusion that the event never fired in production. Running `pup metrics list --filter <name>` showed the
metric is published under an app-namespace prefix (`<app>.<name>`). Re-querying with the prefix showed the event fires
on nearly every login, which reversed the fix plan.

**Root cause:** The app's metrics client prepends a namespace. An empty series is how Datadog reports a metric that
doesn't exist, so the empty result looked like a real zero.

**Suggested fix:** In wk-datadog, before treating an empty series as zero, resolve the full metric name with
`pup metrics list --filter <suffix>` and group by `env`. Treat a no-match query as unknown, never as a count of zero.
