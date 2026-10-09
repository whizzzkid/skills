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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Datadog

Use the `pup` CLI (30+ API domains) for dashboards, monitors, SLOs, and notebooks; prefer it over raw REST/curl and over
the Datadog MCP server.

## Step 1: Authenticate

Run `pup auth status` first; prompt only if it reports unauthenticated. Either mode satisfies: **OAuth2** (preferred,
interactive: user runs `pup auth login`, opens a browser) or **API keys** (headless/CI: env vars below).

```bash
pup auth status || echo "Run: pup auth login   (or set DD_API_KEY + DD_APP_KEY)"
```

- `DD_API_KEY` (key mode): Organization Settings > API Keys.
- `DD_APP_KEY` (key mode): Organization Settings > Application Keys.
- `DD_SITE` (optional): defaults to `datadoghq.com`; e.g. `us3.datadoghq.com`, `us5.datadoghq.com`, `datadoghq.eu`,
  `ap1.datadoghq.com`; or pass `--site`.
- If unauthenticated, ask:
  > "Authenticate the Datadog `pup` CLI: run `pup auth login`, or set
  > `export DD_API_KEY=... DD_APP_KEY=...` (find both under Organization
  > Settings > API / Application Keys)."

## Global flags

`--output json|table|yaml|csv` (default `json`) · `--yes` skips confirmation prompts (see
[Confirm-before-delete](#confirm-before-delete)) · `--site <site>` overrides `DD_SITE` per invocation · `--org <name>`
named session for multi-org.

### HARD RULE: `--no-agent` on any command the user or CI will run

- Agent mode (auto-detected here) wraps responses in a `{status, data, metadata}` envelope; outside it, `pup` emits the
  raw payload.
- Append `--no-agent` to every `pup` command you write into a script, alias, runbook, or hand back for the user/CI to
  run — otherwise their output shape differs from what you tested and downstream `jq` breaks.

  ```bash
  pup --no-agent monitors list --tags='env:prod' | jq '.[].name'
  ```

## File Access Rules

- **HARD RULE:** Write tool may ONLY create temporary JSON payload files (e.g. `dashboard.json`, `monitor.json`,
  `slo.json`, `notebook.json`) in the current directory for `--file` create/update. Never write project source, config,
  or any other path.
- Read may access any path (read-only) to understand existing configurations.

## Step 1.5: Resolve resource-type intent before any write

"Create X per Y" (notebook per PR, dashboard per service) hides two patterns; when the request doesn't make the shape
explicit, ask before creating. Pick the canonical resource:

- Per-entity views, recurring filter (PR, service, env, team) → **one dashboard + template variables** (`$pr_number`,
  `$service`, `$env`).
- Per-incident investigation, post-mortem, ad-hoc free-form notes + queries → **notebook** (or new dashboard) per
  instance.
- Alerting on threshold breach → **monitor**.
- Tracking objective compliance → **SLO**.

Never build a notebook-per-PR when the user wanted one filterable dashboard: it creates thousands of dead artifacts.

## Step 2: Command surface

All domains follow `pup <resource> <action>` over `dashboards`, `monitors`, `slos`, `notebooks`:

- `pup <resource> list [filters]`: filter, never dump (see anti-patterns).
- `pup <resource> get <id>`: add `> file.json` to capture a payload.
- `pup <resource> create --file payload.json`: build the JSON first.
- `pup <resource> update <id> --file payload.json`.
- `pup <resource> delete <id>`: prompts unless `--yes`.
- Missing subcommand: `pup api <METHOD> <path>` (authenticated raw request).
- Discover, don't guess: run `pup <resource> --help` (returns JSON) to confirm exact flags before authoring a command.

### Confirm-before-delete

- **HARD RULE:** confirm with the user before any `delete`, for every resource type.
- `pup` prompts by default. Never pass `--yes` to a delete without explicit user confirmation in this session.

### Error handling

- 400 / validation error: bad payload; show the error body, fix the JSON.
- 401: not authenticated; re-run `pup auth login` (or re-check keys); do not retry blindly.
- 403: missing permissions; verify key/OAuth scopes for the resource.
- 404: not found; verify the ID, `list` to find the correct one.
- 429: rate limited; back off before retrying.

### Anti-patterns (from `pup` itself)

- Never `list` all monitors/SLOs without filters in large orgs: use `--name` / `--tags` / `--query`.
- Never start with `--limit=1000`: start small and refine.
- Never retry a failed request without reading the error (401 vs 403 differ).

## Dashboards

- `pup dashboards list [--filter-title ... | --filter-tags ...]`; `get <id>` (`> dashboard.json` to clone);
  `create --file dashboard.json`; `update <id> --file dashboard.json`; `delete <id>` (confirm first).
- Clone: `get` existing → strip `id` → change title → `create --file`.
- Ask before build: title, description, layout type (`ordered`/`free`), widgets (timeseries, query value, top list,
  heatmap, etc.).

### Widget custom links — log-attribute template expansion

- **HARD RULE — `{{@attr.value}}` for external URLs, `{{@attr}}` for Datadog search URLs.** Mixing them produces broken
  links.
- `{{@attribute}}` → full facet filter `@attribute:value` (e.g. `@repo:{owner}/{repo}`): use only when the target is a
  Datadog search/log URL expecting the full filter.
- `{{@attribute.value}}` → raw value alone (e.g. `{owner}/{repo}`): use for every external URL (GitHub, Jira, PagerDuty,
  Buildkite, internal tools).
- `{{$template_var}}` → empty when the template variable is `*`: never depend on template variables to populate
  external-URL parameters; key off log attributes.
- Classify the link target before authoring: off `*.datadoghq.com` → `{{@attr.value}}`; Datadog search/log URL →
  `{{@attr}}`.

## Monitors

- `pup monitors list [--name=... | --tags=env:prod,team:backend]`; `search --query='...'` (full-text); `get <id>`;
  `create --file monitor.json`; `update <id> --file monitor.json`; `mute <id>` / `unmute <id>`; `delete <id>` (confirm
  first).
- Ask before build: type (`metric alert`, `log alert`, `apm`, `composite`, etc.), query, thresholds
  (critical/warning/ok), notification message, recipients.

## SLOs

- `pup slos list [--query ... | --tags-query team:slo-app]`; `get <id>`; `status <id>` (error budget burn / target
  compliance); `history <id>`; `create --file slo.json`; `update <id> --file slo.json`; `delete <id>` (confirm first).
- Ask before build: type (`metric`/`monitor`/time-slice), name, description, target % (e.g. 99.9), timeframe
  (`7d`/`30d`/`90d`); metric-based: numerator + denominator queries; monitor-based: monitor IDs.

## Notebooks

- `pup notebooks list`; `get <id>`; `create --file notebook.json`; `update <id> --file notebook.json`; `delete <id>`
  (confirm first).
- Ask before build: name, cells (markdown, timeseries, log stream, etc.), time range.

## Requirements

`pup` installed (`brew install datadog-labs/pack/pup`) and `jq`; authenticated via `pup auth login` or `DD_API_KEY` +
`DD_APP_KEY`; network access to `api.${DD_SITE}`.

## Post-Completion

Invoke `wk-learn datadog`.
