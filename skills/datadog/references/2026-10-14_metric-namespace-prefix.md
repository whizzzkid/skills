---
class: principle
---

# Resolve the published metric name before reading an empty series

**Rule**

- Before concluding a metric "never fires", list it with `pup metrics list --filter='*<suffix>'` over a window covering
  the period, re-query the listed name grouped by `env`, and report a no-match as unknown, never zero.

**Why**

- A query for the name exactly as written in app code returned `series: []`. The app's metrics client prepends a
  namespace, so the published name differed. Datadog reports a nonexistent metric as an empty series, not an error, so
  the empty result read as a real zero and nearly inverted a fix plan; the prefixed name showed the event firing on
  nearly every request.
- `pup metrics list` defaults `--from` to `1h`, which can miss a sparse metric.

**Where**

`skills/datadog/SKILL.md` → Metrics → HARD RULE: resolve the published metric name.
