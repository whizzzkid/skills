# Devcontainer Config Templates

## Dockerfile

```dockerfile
FROM ghcr.io/jdx/mise:2026.5.6

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --yes --no-install-recommends \
    build-essential \
    libffi-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Required: redirect Bundler to the named volume path
ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_APP_CONFIG="/usr/local/bundle"

WORKDIR /workspace

CMD ["sleep", "infinity"]
```

- **HARD RULE: Do NOT add `ENV PATH=.../shims` or `echo 'eval "$(mise activate bash)"' >> /etc/bash.bashrc`** -- `jdx/mise` image already configures both; manual additions double-activate.
- **HARD RULE: Do NOT `COPY mise.toml` or `RUN mise install`** -- use `auto_install = true` in `mise.toml` instead.

## docker-compose.yml

```yaml
services:
  app:
    build:
      context: ..              # project root -- Dockerfile is in .devcontainer/
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - ..:/workspace:cached
      - bundle-cache:/usr/local/bundle
      - ${XDG_CONFIG_HOME:-~/.config}/mise/config.toml:/root/.config/mise/config.toml:ro
      - ~/.claude:/root/.claude
    command: sleep infinity
    environment:
      MISE_TRUSTED_CONFIG_PATHS: /workspace
      # Copy CONFIG__ overrides from .buildkite/docker/compose.yml:
      CONFIG__DATABASE__CREDENTIALS: '{"host": "db", "port": 3306, "username": "root", "password": ""}'
      CONFIG__DATABASE__SSL_MODE: preferred   # NOT required -- Docker MySQL has no TLS
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
- `context: ..` -- build context must be project root
- `MISE_TRUSTED_CONFIG_PATHS: /workspace` -- trusts `mise.toml` after bind mount
- `ssl_mode: preferred` -- Docker MySQL has no TLS; `required` causes SSL error
- `depends_on.condition: service_healthy` -- waits for real readiness
- `bundle-cache:/usr/local/bundle` -- persists gems; only works with `BUNDLE_PATH` in Dockerfile
- Host config mounts: `mise/config.toml:ro` (global mise settings), `~/.claude` (Claude Code r/w)

**HARD RULE — never set an env var the app's own bootstrap conditionally defaults.**
An unconditional `environment:` entry beats every `||=`/`:-`/`setdefault`, so the
container silently runs the wrong mode. Before adding a name, grep app bootstrap and
test-harness files; a conditional assignment there → omit it from compose. Symptom:
suite errors in-container on infra missing from the forced mode, passes on host → fix
the compose entry, never a per-invocation override.

## devcontainer.json

```json
{
  "name": "<AppName>",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "postCreateCommand": "bundle install && bin/rails db:create db:migrate",
  "postStartCommand": "mkdir -p .devcontainer/logs && nohup bin/rails server -b 0.0.0.0 -p 3000 > .devcontainer/logs/server.log 2>&1 &",
  "forwardPorts": [3000],
  "portsAttributes": {
    "3000": { "label": "Rails", "onAutoForward": "openBrowser" }
  },
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

- `rubyLsp.rubyVersionManager: mise` -- required; without it Ruby LSP uses system Ruby
- `/workspace/bin` on PATH -- Rails binstubs without `bundle exec`
- `postCreateCommand` runs after workspace mounts
- `postStartCommand` backgrounds the Rails server so connect doesn't block
- `portsAttributes.onAutoForward: openBrowser` auto-opens browser

### Log paths

Write logs inside the workspace bind-mount (visible from host):
- Server output: `.devcontainer/logs/server.log`
- Rails app logs: `log/development.log` (Rails default)
- Add `.devcontainer/logs/` to `.gitignore`
