---
name: wk-datadog
description: >-
  Create, manage, and edit Datadog dashboards, monitors, SLOs, and notebooks
  via the Datadog REST API. Use when asked to create a dashboard, set up a
  monitor, define an SLO, manage notebooks, or interact with Datadog resources.
argument-hint: '[action: list|create|get|update|delete] [resource: dashboard|monitor|slo|notebook]'
allowed-tools:
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
  version: '2026.05.08-182715'
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

## File Access Rules

**HARD RULE:** Write tool may ONLY create temporary JSON payload files
(e.g., `dashboard.json`, `monitor.json`, `slo.json`, `notebook.json`)
in the current directory for API requests. Never write to project source
files, configuration, or any other location.**

Read may access any path (read-only) to understand existing configurations.

## Step 2: Identify the Operation

| Resource | API Version | Base Path |
|----------|-------------|-----------|
| Dashboard | v1 | `${DD_API}/v1/dashboard` |
| Monitor | v1 | `${DD_API}/v1/monitor` |
| SLO | v1 | `${DD_API}/v1/slo` |
| Notebook | v1 | `${DD_API}/v1/notebooks` |

## Common Patterns

### Auth header helper

All requests use these headers:

```bash
DD_HEADERS=(-H "DD-API-KEY: ${DATADOG_API_KEY}" -H "DD-APPLICATION-KEY: ${DATADOG_APP_KEY}" -H "Content-Type: application/json")
```

### Canonical curl skeleton

```bash
# Read (list / get)
curl -s -X GET  "${DD_API}/v1/{resource}[/{id}]" "${DD_HEADERS[@]}" | jq .

# Write (create)
curl -s -X POST "${DD_API}/v1/{resource}" "${DD_HEADERS[@]}" --data @payload.json | jq .

# Write (update)
curl -s -X PUT  "${DD_API}/v1/{resource}/{id}" "${DD_HEADERS[@]}" --data @payload.json | jq .

# Delete (see confirm rule below)
curl -s -X DELETE "${DD_API}/v1/{resource}/{id}" "${DD_HEADERS[@]}"
```

### Confirm-before-delete

**HARD RULE:** Always confirm with the user before issuing any DELETE request,
for every resource type (dashboards, monitors, SLOs, notebooks).

### Error handling

| HTTP Status | Meaning | Action |
|-------------|---------|--------|
| 400 | Bad request | Show the error body, help user fix the JSON payload |
| 403 | Forbidden | Check API/App key permissions, suggest user verify keys |
| 404 | Not found | Verify the resource ID, list resources to find correct one |
| 429 | Rate limited | Wait and retry after the `X-RateLimit-Reset` header value |

---

## Dashboards

Endpoints: `${DD_API}/v1/dashboard[/{dashboard_id}]`

### List / Get

```bash
curl -s -X GET "${DD_API}/v1/dashboard" "${DD_HEADERS[@]}" | jq '.dashboards[] | {id, title, url}'
curl -s -X GET "${DD_API}/v1/dashboard/{dashboard_id}" "${DD_HEADERS[@]}" | jq .
```

### Create / Update

Ask the user for: title, description, layout type (`ordered` or `free`), and
widgets (timeseries, query value, top list, heatmap, etc.).

```bash
curl -s -X POST "${DD_API}/v1/dashboard" "${DD_HEADERS[@]}" --data @dashboard.json | jq '{id, title, url}'
curl -s -X PUT  "${DD_API}/v1/dashboard/{dashboard_id}" "${DD_HEADERS[@]}" --data @dashboard.json | jq '{id, title, url}'
```

### Delete

See [Confirm-before-delete](#confirm-before-delete).

```bash
curl -s -X DELETE "${DD_API}/v1/dashboard/{dashboard_id}" "${DD_HEADERS[@]}"
```

### Clone

Get the existing dashboard, strip the `id` field, modify the title, and POST
as a new dashboard.

---

## Monitors

Endpoints: `${DD_API}/v1/monitor[/{monitor_id}]`

### List / Get

```bash
curl -s -X GET "${DD_API}/v1/monitor" "${DD_HEADERS[@]}" | jq '.[] | {id, name, type, overall_state}'
curl -s -X GET "${DD_API}/v1/monitor?query=tag:env:production" "${DD_HEADERS[@]}"
curl -s -X GET "${DD_API}/v1/monitor/{monitor_id}" "${DD_HEADERS[@]}" | jq .
```

### Create / Update

Ask the user for: monitor type (`metric alert`, `log alert`, `apm`, `process`,
`composite`, etc.), query, thresholds (critical, warning, ok), notification
message, and recipients.

```bash
curl -s -X POST "${DD_API}/v1/monitor" "${DD_HEADERS[@]}" --data @monitor.json | jq '{id, name, type}'
curl -s -X PUT  "${DD_API}/v1/monitor/{monitor_id}" "${DD_HEADERS[@]}" --data @monitor.json | jq '{id, name, type}'
```

### Delete

See [Confirm-before-delete](#confirm-before-delete).

```bash
curl -s -X DELETE "${DD_API}/v1/monitor/{monitor_id}" "${DD_HEADERS[@]}"
```

### Mute / Unmute

```bash
curl -s -X POST "${DD_API}/v1/monitor/{monitor_id}/mute" "${DD_HEADERS[@]}"
curl -s -X POST "${DD_API}/v1/monitor/{monitor_id}/unmute" "${DD_HEADERS[@]}"
```

---

## SLOs

Endpoints: `${DD_API}/v1/slo[/{slo_id}]`

### List / Get

```bash
curl -s -X GET "${DD_API}/v1/slo" "${DD_HEADERS[@]}" | jq '.data[] | {id, name, type}'
curl -s -X GET "${DD_API}/v1/slo/{slo_id}" "${DD_HEADERS[@]}" | jq .
```

### Create / Update

Ask the user for: SLO type (`metric` or `monitor`), name, description, target
percentage (e.g., 99.9), timeframe (`7d`, `30d`, `90d`). For metric-based:
numerator and denominator queries. For monitor-based: monitor IDs.

```bash
curl -s -X POST "${DD_API}/v1/slo" "${DD_HEADERS[@]}" --data @slo.json | jq '.data[] | {id, name, type}'
curl -s -X PUT  "${DD_API}/v1/slo/{slo_id}" "${DD_HEADERS[@]}" --data @slo.json | jq '.data[] | {id, name}'
```

### Delete

See [Confirm-before-delete](#confirm-before-delete).

```bash
curl -s -X DELETE "${DD_API}/v1/slo/{slo_id}" "${DD_HEADERS[@]}"
```

### Get SLO history

```bash
curl -s -X GET "${DD_API}/v1/slo/{slo_id}/history?from_ts={epoch}&to_ts={epoch}" \
  "${DD_HEADERS[@]}" | jq .
```

---

## Notebooks

Endpoints: `${DD_API}/v1/notebooks[/{notebook_id}]`

### List / Get

```bash
curl -s -X GET "${DD_API}/v1/notebooks" "${DD_HEADERS[@]}" | jq '.data[] | {id, attributes: {name: .attributes.name}}'
curl -s -X GET "${DD_API}/v1/notebooks/{notebook_id}" "${DD_HEADERS[@]}" | jq .
```

### Create / Update

Ask the user for: name, cells (markdown text, timeseries, log stream, etc.),
and time range.

```bash
curl -s -X POST "${DD_API}/v1/notebooks" "${DD_HEADERS[@]}" --data @notebook.json | jq '.data | {id, attributes: {name: .attributes.name}}'
curl -s -X PUT  "${DD_API}/v1/notebooks/{notebook_id}" "${DD_HEADERS[@]}" --data @notebook.json | jq '.data | {id}'
```

### Delete

See [Confirm-before-delete](#confirm-before-delete).

```bash
curl -s -X DELETE "${DD_API}/v1/notebooks/{notebook_id}" "${DD_HEADERS[@]}"
```

---

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

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn datadog`).
