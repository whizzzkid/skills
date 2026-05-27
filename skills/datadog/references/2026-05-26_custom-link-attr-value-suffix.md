---
class: principle
date: 2026-05-26
source: learnings/skills/datadog/2026-05-26_log-attr-custom-link-syntax.md
severity: high
---

- **Rule:** Use `{{@attribute.value}}` (with `.value` suffix) in custom-link templates that target external URLs (GitHub, Jira, PagerDuty, Buildkite, internal tools); reserve `{{@attribute}}` (no suffix) for links pointing back at Datadog search/log URLs, where the full `@attr:value` filter prefix is what the URL needs. Dashboard template vars (`{{$var}}`) return empty when set to `*` — do not depend on them for external-URL parameters; key off log attributes instead.
- **Why:** Custom-link expansion of `{{@attr}}` injects the full Datadog facet filter (`@repo:{owner}/{repo}`) into external URLs, producing broken targets. The `.value` suffix yields the raw value alone but is not documented prominently.
- **Where:** Dashboards section — new "Widget custom links — log-attribute template expansion" HARD RULE between Clone and Monitors.
