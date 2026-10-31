# wk-devcontainer

> Use when creating or debugging a devcontainer for a Rails app (or any mise-managed project).

**Version:** `2026.10.31-003026`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | "set up devcontainer", "create devcontainer", "devcontainer not working", "bundle install fails in devcontainer", "mise tools missing in container" |
| Model-invocable | automatic on: devcontainer creation or debugging requests for mise-managed projects |

## How It Works

```mermaid
flowchart TD
    A[Audit project first] --> B[Read .buildkite/docker/compose.yml<br/>config/database.yml<br/>.ruby-version<br/>Gemfile services]
    B --> C[Write Dockerfile<br/>FROM ghcr.io/jdx/mise pinned<br/>BUNDLE_PATH env vars<br/>No PATH wiring]
    C --> D[Write docker-compose.yml<br/>context:..<br/>bundle-cache volume<br/>CONFIG__ overrides from CI<br/>depends_on healthcheck]
    D --> E[Write devcontainer.json<br/>postCreateCommand: bundle install + db:create<br/>rubyLsp.rubyVersionManager: mise]
    E --> F[Update mise.toml<br/>auto_install = true<br/>ruby version matches .ruby-version]
    F --> G[Validate: run postCreateCommand<br/>Check common failure modes]
```

## Noteworthy

- **Check `.buildkite/docker/compose.yml` first** — it is the authoritative source for `CONFIG__` env var keys, service image versions, and SSL mode settings; copy them, don't guess.
- **Never add `ENV PATH=.../shims` or `eval "$(mise activate bash)"` to the Dockerfile** — the `jdx/mise` image already configures both; manual additions cause double-activation bugs.
- **Never `COPY mise.toml` or `RUN mise install` in the Dockerfile** — use `auto_install = true` in `mise.toml` instead; tools install on first container start when the workspace bind-mounts.
- **`BUNDLE_PATH` and `BUNDLE_APP_CONFIG` must both be set** in the Dockerfile to `/usr/local/bundle`; without them the named `bundle-cache` volume is bypassed and gems reinstall on every restart.
- **`trilogy` adapter does not need `libmysqlclient-dev`** — only the `mysql2` adapter links against libmysqlclient; adding it for trilogy is a common unnecessary dependency.
- **`MISE_TRUSTED_CONFIG_PATHS: /workspace` is required** in the compose environment — the bind mount replaces the `/workspace` directory that was trusted at image build time, so trust must be re-granted at runtime.
- **Pin the Compose project name in every teardown/rebuild command** — `devcontainer up`/VS Code create the stack under the lowercased `<basename>_devcontainer` (Compose rejects uppercase project names); a bare `docker compose -f … down` targets an empty project and silently leaves it running.
- **Surface the real build error first** — `devcontainer up` hides the cause behind a generic build failure; a trace log shows it. Under Compose 5.x bake the usual cause is a filesystem entitlement for the CLI's temp features Dockerfile (prefix `BUILDX_BAKE_ENTITLEMENTS_FS=0` on the CLI call). Plain compose is a last resort only when no features are
  declared and nothing relies on `devcontainer exec` — a stack started outside the CLI lacks the labels `exec` finds
  containers by.
- **Host port held by a sibling worktree** — never edit the committed mapping or stop the other stack. A throwaway
  container on the stack's network covers ad hoc work; when hooks call `devcontainer exec`, start this worktree's stack
  with an uncommitted override that resets published ports and stamps the `devcontainer.local_folder` /
  `devcontainer.config_file` labels, then run the post-create steps by hand.
- **Prepare the test DB the way CI does** — `RAILS_ENV=test db:prepare` loads seeds into a fresh DB and skews
  count-based tests; use CI's recipe or `db:test:prepare`.
- **Do not stream startup output when Compose resolves host credentials** — prefer file-backed secrets; otherwise capture under `umask 077`, print only an exact-value-redacted copy, and verify with a canary.
