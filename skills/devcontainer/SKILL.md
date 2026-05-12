---
name: wk-devcontainer
description: >
  Use when creating or debugging a devcontainer for a Rails app (or any
  mise-managed project) — generates Dockerfile, docker-compose.yml, and
  devcontainer.json with correct mise, Bundler, MySQL, and Redis wiring.
  Trigger phrases: "set up devcontainer", "create devcontainer", "devcontainer
  not working", "bundle install fails in devcontainer", "mise tools missing in
  container".
metadata:
  version: 2026.05.12-220540
  model: sonnet
  effort: medium
  user-invocable: true
  model-invocable: true
---

# wk-devcontainer

Create or debug a `.devcontainer/` setup for a mise-managed Rails app.

## When to Use

- Setting up a new devcontainer from scratch
- Debugging broken mise tool resolution, Bundler cache, MySQL/Redis connectivity
- After `postCreateCommand` fails or tools are missing in the container

## Step 1: Audit the project first

**HARD RULE: Check CI compose before writing any config.** The project already
demonstrates the correct Docker override pattern.

```bash
cat .buildkite/docker/compose.yml   # authoritative for CONFIG__ overrides
cat config/database.yml             # which keys drive DB connection
cat .ruby-version                   # pin this exactly in mise.toml
grep -E "redis|sidekiq|elasticsearch" Gemfile | head -10  # extra services needed
```

Read all four. The CI compose shows exact image versions, service names, and
`CONFIG__` env var keys — copy them, don't guess.

## Step 2: Write the Dockerfile

Base image: `ghcr.io/jdx/mise:<version>` — pin to an exact version, never
`latest`. The image is Debian-based (`apt-get` works).

**HARD RULE: Do NOT add `ENV PATH=.../shims` or `echo 'eval "$(mise activate
bash)"' >> /etc/bash.bashrc`.** The `jdx/mise` image already configures both
shim PATH and bash activation. Manual additions cause double-activation bugs.

**HARD RULE: Do NOT `COPY mise.toml` or `RUN mise install` in the Dockerfile.**
Use `auto_install = true` in `mise.toml` instead — tools install on first
container start when the workspace bind-mounts.

```dockerfile
FROM ghcr.io/jdx/mise:2026.5.6

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --yes --no-install-recommends \
    build-essential \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Required: redirect Bundler to the named volume path
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_APP_CONFIG="/usr/local/bundle"

WORKDIR /workspace

CMD ["sleep", "infinity"]
```

`default-libmysqlclient-dev` provides MySQL headers for `trilogy`/`mysql2`
native gems.

## Step 3: Write docker-compose.yml

```yaml
services:
  app:
    build:
      context: ..              # project root — Dockerfile is in .devcontainer/
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - ..:/workspace:cached
      - bundle-cache:/usr/local/bundle
    command: sleep infinity
    environment:
      MISE_TRUSTED_CONFIG_PATHS: /workspace
      # Copy CONFIG__ overrides from .buildkite/docker/compose.yml:
      CONFIG__DATABASE__CREDENTIALS: '{"host": "db", "port": 3306, "username": "root", "password": ""}'
      CONFIG__DATABASE__SSL_MODE: preferred   # NOT required — Docker MySQL has no TLS
      CONFIG__DATABASE__SSL_CAPATH: ""
      CONFIG__REDIS__HOST: redis
      CONFIG__REDIS__SSL: "false"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy

  db:
    image: mysql:8.0.42        # pin to match CI version
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "1"
    healthcheck:
      test: mysql --execute="SELECT 1;"
      interval: 1s
      retries: 60
    volumes:
      - db-data:/var/lib/mysql

  redis:
    image: redis:7.4.9-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 1s
      retries: 30

volumes:
  bundle-cache:
  db-data:
```

Key decisions:
- `context: ..` — build context must be project root, not `.devcontainer/`
- `MISE_TRUSTED_CONFIG_PATHS: /workspace` — trusts `mise.toml` after bind mount replaces `/workspace`
- `ssl_mode: preferred` — Docker MySQL has no TLS; `required` causes `SSL is required but the server doesn't support it`
- `depends_on.condition: service_healthy` — waits for real readiness, not just container start
- `bundle-cache:/usr/local/bundle` — persists gems across restarts (only works with `BUNDLE_PATH` set in Dockerfile)

## Step 4: Write devcontainer.json

```json
{
  "name": "<AppName>",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "postCreateCommand": "bundle install && bin/rails db:create db:migrate",
  "forwardPorts": [3000],
  "remoteEnv": {
    "PATH": "${containerEnv:PATH}:/workspace/bin"
  },
  "customizations": {
    "vscode": {
      "extensions": ["Shopify.ruby-lsp", "eamodio.gitlens"],
      "settings": {
        "rubyLsp.rubyVersionManager": { "identifier": "mise" }
      }
    }
  }
}
```

- `rubyLsp.rubyVersionManager: mise` — required; without it Ruby LSP uses system Ruby
- `/workspace/bin` on PATH — Rails binstubs without `bundle exec` prefix
- `forwardPorts: [3000]` — avoids manual port forwarding for the Rails server
- `postCreateCommand` runs after workspace mounts, so `bundle install` has access to the bind-mounted Gemfile

## Step 5: Update mise.toml

Add to the project's `mise.toml`:

```toml
[settings]
auto_install = true   # install tools on container start, no COPY+install at build time

[tools]
ruby = "3.4.7"   # must match .ruby-version exactly
```

Ruby version must match `.ruby-version` exactly — mismatch causes Bundler
lockfile platform conflicts.

## Common Mistakes

| Symptom | Root cause | Fix |
|---------|-----------|-----|
| `ruby: command not found` in postCreateCommand | Manual `ENV PATH` or `mise activate` line missing (old pattern) — or jdx/mise image version predates built-in activation | Upgrade to `ghcr.io/jdx/mise:2026.5.6+`; remove manual PATH/activate lines |
| Gems reinstall on every restart | `BUNDLE_PATH` not set in Dockerfile; named volume bypassed | Add `ENV BUNDLE_PATH="/usr/local/bundle"` and `ENV BUNDLE_APP_CONFIG="/usr/local/bundle"` |
| `SSL is required but the server doesn't support it` | `CONFIG__DATABASE__SSL_MODE: required` | Change to `preferred` |
| `mise.toml is not trusted` | Bind mount replaces the `/workspace` that was trusted at build time | Set `MISE_TRUSTED_CONFIG_PATHS: /workspace` in compose environment |
| Build fails: file not found during COPY | `context: .devcontainer` instead of project root | Set `context: ..` on the app build |
| DB connection uses `localhost` | Service hostname confusion | Use `db` (service name) as MySQL host inside Compose network |
| Tools silently absent | `auto_install = true` missing from `mise.toml` | Add `[settings] auto_install = true` |

## Quick Reference

```
.devcontainer/
├── Dockerfile          # FROM ghcr.io/jdx/mise:<version>, no PATH wiring
├── docker-compose.yml  # app + db + redis, context: ..
└── devcontainer.json   # postCreateCommand, rubyLsp.rubyVersionManager: mise
```

Investigation order for a new project:
1. `.buildkite/docker/compose.yml` — CONFIG__ override pattern + image versions
2. `config/database.yml` — DB config keys
3. `.ruby-version` — exact Ruby version for mise.toml
4. `Gemfile` — extra services (Sidekiq, Elasticsearch, etc.)

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn devcontainer`).
