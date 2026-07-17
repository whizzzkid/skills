---
class: principle
---

**Rule** — Interact with Datadog through the `pup` CLI (`pup <resource> <action>`),
not raw REST/curl and not the Datadog MCP server. Full CRUD exists for dashboards,
monitors, SLOs, and notebooks; `pup api <METHOD> <path>` covers anything without a
dedicated subcommand.

**Why** — `pup` is Datadog's agent-ready CLI: consistent auth (OAuth2 `pup auth login`
or `DD_API_KEY`/`DD_APP_KEY`), structured JSON output, per-domain `--help` schemas, and
built-in confirmation prompts on deletes. It removes hand-rolled curl signing, header,
and error-parsing boilerplate.

**Where** — Auth: `pup auth status` / `pup auth login`. Create/update take `--file
payload.json`. Global flags: `--output`, `--yes`, `--site`, `--org`. Agent mode wraps
output in a `{status, data, metadata}` envelope — append `--no-agent` to any command a
user or CI will run so the raw-payload shape matches.
