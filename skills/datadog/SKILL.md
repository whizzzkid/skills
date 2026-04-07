---
name: wk:datadog
description: >-
  Create, manage, and edit Datadog dashboards, monitors, SLOs, and notebooks
  via the Datadog REST API. Use when asked to create a dashboard, set up a
  monitor, define an SLO, manage notebooks, or interact with Datadog resources.
argument-hint: '[action: list|create|get|update|delete] [resource: dashboard|monitor|slo|notebook]'
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
model: sonnet
effort: medium
disable-model-invocation: false
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Datadog

Create, manage, and edit Datadog dashboards, monitors, SLOs, and notebooks
via the Datadog REST API using curl.

## Step 1: Authenticate

Check for required environment variables. If any are missing, ask the user
to provide them.

```bash
: "${DATADOG_API_KEY:?Set DATADOG_API_KEY env var}"
: "${DATADOG_APP_KEY:?Set DATADOG_APP_KEY env var}"
DD_SITE="${DATADOG_SITE:-datadoghq.com}"
DD_API="https://api.${DD_SITE}/api"
```

| Variable | Required | Description |
|----------|----------|-------------|
| `DATADOG_API_KEY` | Yes | API key from Organization Settings > API Keys |
| `DATADOG_APP_KEY` | Yes | Application key from Organization Settings > Application Keys |
| `DATADOG_SITE` | No | Defaults to `datadoghq.com`. Options: `us3.datadoghq.com`, `us5.datadoghq.com`, `datadoghq.eu`, `ap1.datadoghq.com` |

If keys are missing, ask:
> "I need your Datadog API key and Application key to proceed. You can find
> these in Datadog under Organization Settings > API Keys / Application Keys.
> Set them as environment variables:
> `export DATADOG_API_KEY=... DATADOG_APP_KEY=...`"

### Auth header helper

All requests use these headers:

```bash
DD_HEADERS=(-H "DD-API-KEY: ${DATADOG_API_KEY}" -H "DD-APPLICATION-KEY: ${DATADOG_APP_KEY}" -H "Content-Type: application/json")
```

## Step 2: Identify the Operation

Determine what the user wants from their request:

| Resource | API Version | Base Path |
|----------|-------------|-----------|
| Dashboard | v1 | `${DD_API}/v1/dashboard` |
| Monitor | v1 | `${DD_API}/v1/monitor` |
| SLO | v1 | `${DD_API}/v1/slo` |
| Notebook | v1 | `${DD_API}/v1/notebooks` |

## Dashboards

### List dashboards

```bash
curl -s -X GET "${DD_API}/v1/dashboard" "${DD_HEADERS[@]}" | jq '.dashboards[] | {id, title, url}'
```

### Get dashboard by ID

```bash
curl -s -X GET "${DD_API}/v1/dashboard/{dashboard_id}" "${DD_HEADERS[@]}" | jq .
```

### Create dashboard

Build a JSON definition and POST it. Ask the user for:
- Title and description
- Layout type: `ordered` (grid) or `free` (freeform)
- Widgets to include (timeseries, query value, top list, heatmap, etc.)

```bash
curl -s -X POST "${DD_API}/v1/dashboard" "${DD_HEADERS[@]}" \
  --data @dashboard.json | jq '{id, title, url}'
```

### Update dashboard

```bash
curl -s -X PUT "${DD_API}/v1/dashboard/{dashboard_id}" "${DD_HEADERS[@]}" \
  --data @dashboard.json | jq '{id, title, url}'
```

### Delete dashboard

**Always confirm with the user before deleting.**

```bash
curl -s -X DELETE "${DD_API}/v1/dashboard/{dashboard_id}" "${DD_HEADERS[@]}"
```

### Clone dashboard

Get the existing dashboard, strip the `id` field, modify the title, and POST
as a new dashboard.

## Monitors

### List monitors

```bash
curl -s -X GET "${DD_API}/v1/monitor" "${DD_HEADERS[@]}" | jq '.[] | {id, name, type, overall_state}'
```

Search with query parameter:

```bash
curl -s -X GET "${DD_API}/v1/monitor?query=tag:env:production" "${DD_HEADERS[@]}"
```

### Get monitor by ID

```bash
curl -s -X GET "${DD_API}/v1/monitor/{monitor_id}" "${DD_HEADERS[@]}" | jq .
```

### Create monitor

Ask the user for:
- Monitor type: `metric alert`, `log alert`, `apm`, `process`, `composite`, etc.
- Query (metric query, log query, etc.)
- Thresholds (critical, warning, ok)
- Notification message and recipients

```bash
curl -s -X POST "${DD_API}/v1/monitor" "${DD_HEADERS[@]}" \
  --data @monitor.json | jq '{id, name, type}'
```

### Update monitor

```bash
curl -s -X PUT "${DD_API}/v1/monitor/{monitor_id}" "${DD_HEADERS[@]}" \
  --data @monitor.json | jq '{id, name, type}'
```

### Delete monitor

**Always confirm with the user before deleting.**

```bash
curl -s -X DELETE "${DD_API}/v1/monitor/{monitor_id}" "${DD_HEADERS[@]}"
```

### Mute / Unmute monitor

```bash
# Mute
curl -s -X POST "${DD_API}/v1/monitor/{monitor_id}/mute" "${DD_HEADERS[@]}"

# Unmute
curl -s -X POST "${DD_API}/v1/monitor/{monitor_id}/unmute" "${DD_HEADERS[@]}"
```

## SLOs

### List SLOs

```bash
curl -s -X GET "${DD_API}/v1/slo" "${DD_HEADERS[@]}" | jq '.data[] | {id, name, type}'
```

### Get SLO by ID

```bash
curl -s -X GET "${DD_API}/v1/slo/{slo_id}" "${DD_HEADERS[@]}" | jq .
```

### Create SLO

Ask the user for:
- SLO type: `metric` or `monitor`
- Name and description
- Target percentage (e.g., 99.9)
- Timeframe: `7d`, `30d`, `90d`
- For metric-based: numerator and denominator queries
- For monitor-based: monitor IDs

```bash
curl -s -X POST "${DD_API}/v1/slo" "${DD_HEADERS[@]}" \
  --data @slo.json | jq '.data[] | {id, name, type}'
```

### Update SLO

```bash
curl -s -X PUT "${DD_API}/v1/slo/{slo_id}" "${DD_HEADERS[@]}" \
  --data @slo.json | jq '.data[] | {id, name}'
```

### Delete SLO

**Always confirm with the user before deleting.**

```bash
curl -s -X DELETE "${DD_API}/v1/slo/{slo_id}" "${DD_HEADERS[@]}"
```

### Get SLO history

```bash
curl -s -X GET "${DD_API}/v1/slo/{slo_id}/history?from_ts={epoch}&to_ts={epoch}" \
  "${DD_HEADERS[@]}" | jq .
```

## Notebooks

### List notebooks

```bash
curl -s -X GET "${DD_API}/v1/notebooks" "${DD_HEADERS[@]}" | jq '.data[] | {id, attributes: {name: .attributes.name}}'
```

### Get notebook by ID

```bash
curl -s -X GET "${DD_API}/v1/notebooks/{notebook_id}" "${DD_HEADERS[@]}" | jq .
```

### Create notebook

Ask the user for:
- Name
- Cells (markdown text, timeseries, log stream, etc.)
- Time range

```bash
curl -s -X POST "${DD_API}/v1/notebooks" "${DD_HEADERS[@]}" \
  --data @notebook.json | jq '.data | {id, attributes: {name: .attributes.name}}'
```

### Update notebook

```bash
curl -s -X PUT "${DD_API}/v1/notebooks/{notebook_id}" "${DD_HEADERS[@]}" \
  --data @notebook.json | jq '.data | {id}'
```

### Delete notebook

**Always confirm with the user before deleting.**

```bash
curl -s -X DELETE "${DD_API}/v1/notebooks/{notebook_id}" "${DD_HEADERS[@]}"
```

## Error Handling

| HTTP Status | Meaning | Action |
|-------------|---------|--------|
| 400 | Bad request | Show the error body, help user fix the JSON payload |
| 403 | Forbidden | Check API/App key permissions, suggest user verify keys |
| 404 | Not found | Verify the resource ID, list resources to find correct one |
| 429 | Rate limited | Wait and retry after the `X-RateLimit-Reset` header value |

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "create a dashboard" | Ask for details, build JSON, POST to Datadog API |
| "list my monitors" | GET monitors, show summary table |
| "set up an SLO" | Walk through SLO type, target, timeframe, create |
| "create a notebook" | Ask for name and cells, POST to API |
| "delete monitor X" | Confirm with user, then DELETE |

## Requirements

- `curl` and `jq` installed
- `DATADOG_API_KEY` and `DATADOG_APP_KEY` environment variables set
- Network access to `api.${DATADOG_SITE}`
