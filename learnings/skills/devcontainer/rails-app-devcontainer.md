# Devcontainer Setup Learnings: Rails App with MySQL + Redis

## Pattern Overview

A devcontainer for a Rails app needs:
1. A `Dockerfile` based on `jdx/mise` to manage Ruby and other dev tools
2. A `docker-compose.yml` with the app + MySQL + Redis services
3. A `devcontainer.json` wiring them together for VS Code

---

## Base Image

Use `ghcr.io/jdx/mise:<version>` (e.g., `ghcr.io/jdx/mise:2026.5.6`).

- **Pin to exact version** — never use `latest`
- The mise image is Debian/Ubuntu-based; `apt-get` works
- `mise` binary is pre-installed in the image

### System deps needed for a Ruby/Rails app

```dockerfile
RUN apt-get update && apt-get install --yes --no-install-recommends \
    build-essential \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*
```

`default-libmysqlclient-dev` is the Debian package that provides MySQL headers for native gems like `trilogy` and `mysql2`.

### mise PATH: shims + interactive activation — BOTH required

```dockerfile
# Shims on PATH for non-interactive contexts (postCreateCommand, VS Code tasks, exec)
ENV PATH="/root/.local/share/mise/shims:${PATH}"

# Activate mise for interactive bash sessions (completions, version switching)
RUN echo 'eval "$(mise activate bash)"' >> /etc/bash.bashrc
```

**Critical:** `/etc/bash.bashrc` is only sourced for interactive shells. `postCreateCommand` runs in a non-interactive shell, so `mise activate` never fires there. Without the `ENV PATH` shims line, `ruby`, `bundle`, and all mise-managed tools are missing when `postCreateCommand` runs, causing immediate failure. You need both: shims for non-interactive and `activate` for interactive.

### Pre-installing tools at build time

```dockerfile
COPY mise.toml .ruby-version ./
RUN mise trust --yes && mise install
```

Copying only the version manifests (not the full source tree) ensures the image layer is stable and tools are pre-installed before the workspace is mounted.

### Keep the container alive for devcontainer

```dockerfile
CMD ["sleep", "infinity"]
```

VS Code attaches to the running container; it needs something to keep the container alive.

---

## docker-compose.yml

### Service hostnames

Inside Docker Compose, services communicate by **service name** as hostname. The Rails app connects to `db` (not `localhost`) for MySQL and `redis` for Redis.

### $EMPLOYER-specific: CONFIG__ env var overrides

The project uses `$EMPLOYER-config` which merges `$EMPLOYER_config.yml` per-environment. Override specific keys at runtime via `CONFIG__<DOTTED_KEY_AS_DOUBLE_UNDERSCORES>`:

```yaml
CONFIG__DATABASE__CREDENTIALS: '{"host": "db", "port": 3306, "username": "root", "password": ""}'
CONFIG__DATABASE__SSL_MODE: required
CONFIG__DATABASE__SSL_CAPATH: ""
CONFIG__REDIS__HOST: redis
CONFIG__REDIS__SSL: "false"
```

This is the same pattern used in `.buildkite/docker/compose.yml` for CI. Always check CI's compose file first — it's the reference for how the project overrides config in Docker.

### MySQL service

```yaml
db:
  image: mysql:8.0.42
  environment:
    MYSQL_ALLOW_EMPTY_PASSWORD: "1"
  healthcheck:
    test: mysql --execute="SELECT 1;"
    interval: 1s
    retries: 60
  volumes:
    - db-data:/var/lib/mysql
```

Pin to same MySQL version as CI (`mysql:8.0.42` in this project). Use a named volume for data persistence across container restarts.

### Redis service

```yaml
redis:
  image: redis:7.4.9-alpine
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 1s
    retries: 30
```

Use `-alpine` variant for smaller image size.

### Bundle cache volume + BUNDLE_PATH

```dockerfile
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_APP_CONFIG="/usr/local/bundle"
```

```yaml
volumes:
  - bundle-cache:/usr/local/bundle
```

**Critical:** The named volume alone is not enough. mise-managed Ruby installs gems under `~/.local/share/mise/installs/ruby/<version>/...` by default, not `/usr/local/bundle`. You must set `BUNDLE_PATH` (and `BUNDLE_APP_CONFIG`) in the Dockerfile ENV so Bundler actually uses that volume. Without this, every container restart re-downloads all gems.

### app service

```yaml
app:
  build:
    context: ..             # project root (devcontainer/ is a subdirectory)
    dockerfile: .devcontainer/Dockerfile
  volumes:
    - ..:/workspace:cached  # mount the project root
    - bundle-cache:/usr/local/bundle
  command: sleep infinity
  depends_on:
    db:
      condition: service_healthy
    redis:
      condition: service_healthy
```

`context: ..` is important — the Dockerfile COPYs `mise.toml` from the project root, so the build context must be the project root.

---

## devcontainer.json

```json
{
  "name": "App Name",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "postCreateCommand": "bundle install && bin/rails db:create db:migrate",
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

Key points:
- `postCreateCommand` runs **after the container starts and the workspace is mounted** — the right place for `bundle install` and DB setup
- `rubyLsp.rubyVersionManager` must be set to `mise` so Ruby LSP uses the mise-managed Ruby, not system Ruby
- `/workspace/bin` on PATH gives access to Rails binstubs without prefixing `bundle exec`

---

## mise.toml: what to add

For a Ruby project, add to `[tools]`:

```toml
ruby = "3.4.7"   # match .ruby-version exactly
gh = "2.92.0"    # GitHub CLI for PR workflows
```

Ruby version must match `.ruby-version` exactly to avoid Bundler lockfile conflicts.

---

## Investigation Checklist for New Projects

1. **Check `.buildkite/docker/compose.yml`** — it shows the exact MySQL/Redis versions used in CI and how config is overridden (the `CONFIG__` pattern)
2. **Check `config/database.yml`** — shows which config keys drive the DB connection
3. **Check `config/redis.rb`** or equivalent — shows Redis host config key
4. **Check `config/$EMPLOYER_config.yml` or equivalent** — shows default values and available override keys
5. **Check `Gemfile` for Sidekiq, Elasticsearch, etc.** — add those as additional services
6. **Check `.ruby-version`** — pin Ruby in mise.toml to this exact version

---

## Common Gotchas

- **`mise activate` not called** → tools not on PATH in VS Code terminal → add to `/etc/bash.bashrc`
- **Build context is `.devcontainer/`** but Dockerfile copies from project root → set `context: ..`
- **Service hostnames** — `localhost` won't resolve to MySQL/Redis inside Docker; use the service name (`db`, `redis`)
- **Database SSL** — Docker MySQL has no TLS configured by default. `ssl_mode: required` causes connection refusal (`SSL is required but the server doesn't support it`). Use `ssl_mode: preferred` (tries TLS, degrades gracefully). Also set `CONFIG__DATABASE__SSL_CAPATH: ""`  to clear the cert path that only exists in AWS environments.
- **mise trust across bind mounts** — `mise trust --yes` at build time trusts the copied `mise.toml` at `/workspace/mise.toml`. At runtime the bind mount replaces `/workspace`. Set `MISE_TRUSTED_CONFIG_PATHS=/workspace` in the compose environment so the workspace `mise.toml` stays trusted after mount.
- **Forward port 3000** in `devcontainer.json` (`"forwardPorts": [3000]`) so the Rails server is accessible from the host without manual forwarding.
- **`mise trust` required** — when copying mise.toml into the image, run `mise trust --yes` before `mise install` to avoid interactive prompts
