---
name: wk-datadog
description: >-
  Create, manage, and edit Datadog dashboards, monitors, SLOs, and notebooks
  via the `pup` CLI (Datadog's agent-ready command-line interface). Use when
  asked to create a dashboard, set up a monitor, define an SLO, manage
  notebooks, or interact with Datadog resources.
argument-hint: '[action: list|get|create|update|delete] [resource: dashboard|monitor|slo|notebook]'
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.07.28-171038"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Datadog

Manage Datadog dashboards, monitors, SLOs, and notebooks via the `pup` CLI —
Datadog's agent-ready CLI over 30+ API domains. Prefer `pup` over raw REST/curl
and over the Datadog MCP server.

## Step 1: Authenticate

- Verify auth first: `pup auth status`. Only prompt if it reports unauthenticated.
- Two auth modes — either satisfies:
  - **OAuth2 (preferred, interactive):** ask the user to run `pup auth login` (opens a browser).
  - **API keys (headless/CI):** env vars below.

```bash
pup auth status || echo "Run: pup auth login   (or set DD_API_KEY + DD_APP_KEY)"
```

| Variable | Required | Description |
|----------|----------|-------------|
| `DD_API_KEY` | Key mode | API key — Organization Settings > API Keys |
| `DD_APP_KEY` | Key mode | Application key — Organization Settings > Application Keys |
| `DD_SITE` | No | Defaults to `datadoghq.com`. e.g. `us3.datadoghq.com`, `us5.datadoghq.com`, `datadoghq.eu`, `ap1.datadoghq.com`. Or pass `--site`. |

- If unauthenticated, ask:
  > "Authenticate the Datadog `pup` CLI: run `pup auth login`, or set
  > `export DD_API_KEY=... DD_APP_KEY=...` (find both under Organization
  > Settings > API / Application Keys)."

## Global flags

- `--output json|table|yaml|csv` — default `json`.
- `--yes` — skip confirmation prompts (see [Confirm-before-delete](#confirm-before-delete)).
- `--site <site>` — override `DD_SITE` per invocation.
- `--org <name>` — named session for multi-org.

### HARD RULE: `--no-agent` on any command the user or CI will run

- Agent mode (auto-detected here) wraps responses in a `{status, data, metadata}` envelope; outside it, `pup` emits the raw payload.
- Append `--no-agent` to every `pup` command you write into a script, alias, runbook, or hand back for the user/CI to run — otherwise their output shape differs from what you tested and downstream `jq` breaks.

  ```bash
  pup --no-agent monitors list --tags='env:prod' | jq '.[].name'
  ```

## File Access Rules

- **HARD RULE:** Write tool may ONLY create temporary JSON payload files (e.g. `dashboard.json`, `monitor.json`, `slo.json`, `notebook.json`) in the current directory for `--file` create/update. Never write project source, config, or any other path.
- Read may access any path (read-only) to understand existing configurations.

## Step 1.5: Resolve resource-type intent before any write

- "create X per Y" (e.g. "notebook per PR", "dashboard per service") shares phrasing across two distinct patterns → clarify artifact shape before building.
- **One reusable resource filtered by Y** → dashboard with template variables (`$pr_number`, `$service`, `$env`). Default for per-entity views, per-service health, per-team status.
- **A new resource per Y instance** → notebook or new dashboard per incident / investigation. Default for one-off forensic work, post-mortems, ad-hoc analysis.
- Distinction not explicit in request → ask before creating. Pick the canonical pattern:

| User intent | Canonical resource |
|-------------|--------------------|
| Per-entity views, recurring filter (PR, service, env) | Dashboard + template variables |
| Per-incident investigation, free-form notes + queries | Notebook |
| Alerting on threshold breach | Monitor |
| Tracking objective compliance | SLO |

- Building a notebook-per-PR when the user wanted one filterable dashboard creates thousands of dead artifacts.

## Step 2: Command surface

All domains follow `pup <resource> <action>`. Resources: `dashboards`, `monitors`, `slos`, `notebooks`.

| Action | Pattern | Notes |
|--------|---------|-------|
| List | `pup <resource> list [filters]` | Filter, don't dump — see anti-patterns |
| Get | `pup <resource> get <id>` | `> file.json` to capture a payload |
| Create | `pup <resource> create --file payload.json` | Build JSON first |
| Update | `pup <resource> update <id> --file payload.json` | |
| Delete | `pup <resource> delete <id>` | Prompts unless `--yes` |

- **Escape hatch:** for any API `pup` lacks a subcommand for, use `pup api <METHOD> <path>` (authenticated raw request).
- **Discover, don't guess:** run `pup <resource> --help` (returns JSON) to confirm exact flags before authoring a command.

### Confirm-before-delete

- **HARD RULE:** confirm with the user before any `delete`, for every resource type.
- `pup` prompts by default. Never pass `--yes` to a delete without explicit user confirmation in this session.

### Error handling

| Symptom | Meaning | Action |
|---------|---------|--------|
| 400 / validation error | Bad payload | Show the error body; fix the JSON |
| 401 | Not authenticated | Re-run `pup auth login` (or re-check keys) — do not retry blindly |
| 403 | Missing permissions | Verify the key/OAuth scopes for the resource |
| 404 | Not found | Verify the ID; `list` to find the correct one |
| 429 | Rate limited | Back off before retrying |

### Anti-patterns (from `pup` itself)

- Don't `list` all monitors/SLOs without filters in large orgs — use `--name` / `--tags` / `--query`.
- Don't start with `--limit=1000`; start small and refine.
- Don't retry a failed request without reading the error (401 vs 403 differ).

---

## Dashboards

- `pup dashboards list [--filter-title ... | --filter-tags ...]`
- `pup dashboards get <id>` — add `> dashboard.json` to capture for cloning.
- `pup dashboards create --file dashboard.json`
- `pup dashboards update <id> --file dashboard.json`
- `pup dashboards delete <id>` (confirm first)
- **Clone:** `get` existing → strip `id` → change title → `create --file`.

Ask before build: title, description, layout type (`ordered`/`free`), widgets (timeseries, query value, top list, heatmap, etc.).

### Widget custom links — log-attribute template expansion

- **HARD RULE — `{{@attr.value}}` for external URLs, `{{@attr}}` for Datadog search URLs.** Mixing them produces broken links.
- `{{@attribute}}` → full Datadog facet filter `@attribute:value` (e.g. `@repo:{owner}/{repo}`). Use only when the target is a Datadog search/log URL expecting the full filter.
- `{{@attribute.value}}` → raw value alone (e.g. `{owner}/{repo}`). Use for every external URL — GitHub, Jira, PagerDuty, Buildkite, internal tools.
- `{{$template_var}}` → empty when the template variable is `*`. Do not depend on template variables to populate external-URL parameters; key off log attributes.
- Classify link target before authoring: off `*.datadoghq.com` → `{{@attr.value}}`; Datadog search/log URL → `{{@attr}}`.

---

## Monitors

- `pup monitors list [--name=... | --tags=env:prod,team:backend]`
- `pup monitors search --query='...'` — full-text search.
- `pup monitors get <id>`
- `pup monitors create --file monitor.json`
- `pup monitors update <id> --file monitor.json`
- `pup monitors mute <id>` / `pup monitors unmute <id>`
- `pup monitors delete <id>` (confirm first)

Ask before build: type (`metric alert`, `log alert`, `apm`, `composite`, etc.), query, thresholds (critical/warning/ok), notification message, recipients.

---

## SLOs

- `pup slos list [--query ... | --tags-query team:slo-app]`
- `pup slos get <id>`
- `pup slos status <id>` — error budget burn / target compliance.
- `pup slos history <id>` — historical data.
- `pup slos create --file slo.json`
- `pup slos update <id> --file slo.json`
- `pup slos delete <id>` (confirm first)

Ask before build: type (`metric`/`monitor`/time-slice), name, description, target % (e.g. 99.9), timeframe (`7d`/`30d`/`90d`). Metric-based: numerator + denominator queries. Monitor-based: monitor IDs.

---

## Notebooks

- `pup notebooks list`
- `pup notebooks get <id>`
- `pup notebooks create --file notebook.json`
- `pup notebooks update <id> --file notebook.json`
- `pup notebooks delete <id>` (confirm first)

Ask before build: name, cells (markdown, timeseries, log stream, etc.), time range.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "create a dashboard" | Ask for details, build JSON, `pup dashboards create --file` |
| "list my monitors" | `pup monitors list` with filters, show summary |
| "set up an SLO" | Walk through type/target/timeframe, `pup slos create --file` |
| "create a notebook" | Ask for name + cells, `pup notebooks create --file` |
| "delete monitor X" | Confirm, then `pup monitors delete <id>` |

## Requirements

- `pup` CLI installed (`brew install datadog-labs/pack/pup`) and `jq`.
- Authenticated via `pup auth login`, or `DD_API_KEY` + `DD_APP_KEY` set.
- Network access to `api.${DD_SITE}`.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn datadog`).
