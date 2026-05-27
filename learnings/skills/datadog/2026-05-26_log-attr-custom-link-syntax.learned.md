---
skill: wk-datadog
date: 2026-05-26
type: correction
severity: high
---

Log attribute custom links require `.value` suffix to get the raw value.

**What happened:** Custom links in log analytics toplist widgets using `{{@repo}}` and `{{@pr_number}}` expanded to the full Datadog facet filter string (e.g., `@repo:{owner}/{repo}`) instead of just the value, producing broken external URLs. Using `{{$template_var}}` gave an empty string when the variable was set to `*`.

**Root cause:** Datadog custom link template expansion for log attributes has two modes: `{{@attr}}` gives the full filter string `@attr:value` (for passing to Datadog search), while `{{@attr.value}}` gives only the raw value (for external URLs). This `.value` suffix is not documented prominently and is counterintuitive.

**Suggested fix:** Always use `{{@attribute.value}}` (with `.value` suffix) in custom links that target external URLs (GitHub, Jira, PagerDuty, etc.). Reserve `{{@attribute}}` only when constructing Datadog search query URLs. Document this in the skill under the custom links section.
