# Devcontainer Setup: Rails + mise + MySQL + Redis

## Final Dockerfile pattern

```dockerfile
FROM ghcr.io/jdx/mise:2026.5.6

ARG DEBIAN_FRONTEND=noninteractive

# Minimum system deps for native Ruby gem compilation.
# curl and git are already in the mise base image.
# trilogy implements the MySQL wire protocol natively — no libmysqlclient needed.
# mise Ruby ships pre-built with OpenSSL compiled in — no libssl-dev needed.
RUN apt-get update && apt-get install --yes --no-install-recommends \
    build-essential \
    libffi-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH="/usr/local/bundle"
ENV BUNDLE_APP_CONFIG="/usr/local/bundle"

WORKDIR /workspace

CMD ["sleep", "infinity"]
```

## Apt package audit — what stays, what goes, and why

### KEEP

| Package | Why |
|---|---|
| `build-essential` | C compiler + make — required for any gem with a C extension |
| `libffi-dev` | `ffi` gem links against libffi at compile time; widely used transitive dep |
| `pkg-config` | Used by native gem builds to locate system libraries (e.g., libffi) |

### REMOVE

| Package | Why removed |
|---|---|
| `curl` | Already in the jdx/mise base image (mise needs it to download tools) |
| `git` | Already in the jdx/mise base image |
| `default-libmysqlclient-dev` | `trilogy` implements the MySQL wire protocol in C itself — it does NOT link against `libmysqlclient`; no headers needed |
| `libssl-dev` | mise Ruby is a pre-built binary with OpenSSL compiled in; the `openssl` gem ships pre-compiled with Ruby and doesn't need system headers at bundle install time |

### Caveat: libssl-dev

If `bundle install` fails with an OpenSSL compile error (e.g., a gem version
that isn't pre-built for the Ruby/platform combination), add `libssl-dev` back.
This can happen when a gem locks an `openssl` version that doesn't match the
one bundled with the mise Ruby binary.

## mise.toml: auto_install handles tool installation

```toml
[settings]
auto_install = true

[tools]
ruby = "3.4.7"   # exact match to .ruby-version
gh = "2.92.0"
```

No `COPY mise.toml + RUN mise install` needed in the Dockerfile. The jdx/mise
image handles shim PATH and bash activation — do NOT add manual `ENV PATH=.../shims`
or `echo 'eval "$(mise activate bash)"' >> /etc/bash.bashrc`; those are already
baked into the image.

## docker-compose.yml key env vars

```yaml
services:
  app:
    environment:
      RAILS_ENV: development
      APP_ENV: development
      CONFIG__DATABASE__CREDENTIALS: '{"host": "db", "port": 3306, "username": "root", "password": ""}'
      CONFIG__DATABASE__SSL_MODE: preferred   # Docker MySQL has no TLS; "required" refuses
      CONFIG__DATABASE__SSL_CAPATH: ""
      CONFIG__REDIS__HOST: redis
      CONFIG__REDIS__SSL: "false"
      MISE_TRUSTED_CONFIG_PATHS: /workspace   # trust workspace mise.toml after bind mount
    volumes:
      - ..:/workspace:cached
      - bundle-cache:/usr/local/bundle        # only works because BUNDLE_PATH is set in Dockerfile
```

## devcontainer.json essentials

```json
{
  "postCreateCommand": "bundle install && bin/rails db:create db:migrate",
  "forwardPorts": [3000],
  "customizations": {
    "vscode": {
      "settings": {
        "rubyLsp.rubyVersionManager": { "identifier": "mise" }
      }
    }
  }
}
```

## Investigation checklist for new projects

1. Check `.buildkite/docker/compose.yml` — authoritative reference for Docker config overrides (do not crawl gem source)
2. Check which DB adapter is used (`trilogy` vs `mysql2`) — only `mysql2` needs `libmysqlclient-dev`
3. Check `.ruby-version` — pin `ruby` in `mise.toml` to the exact same version
4. Check `Gemfile` for other native services (Elasticsearch, Redis, etc.) — add as compose services
5. Verify `ssl_mode` in `$EMPLOYER_config.yml` — override to `preferred` for local Docker MySQL

## mise profiles: separate host tools from container tools

Use `MISE_PROFILE=devcontainer` in docker-compose + a `mise.devcontainer.toml`
file to install container-specific tools (e.g. `gh`) only inside the container.
The base `mise.toml` stays lean for host developers.

**mise.toml** (everyone):
```toml
[settings]
auto_install = true

[tools]
lefthook = "latest"
ruby = "3.4.7"
```

**mise.devcontainer.toml** (container only):
```toml
[tools]
gh = "2.92.0"
```

**docker-compose.yml** environment:
```yaml
MISE_PROFILE: devcontainer
```

mise merges `mise.toml` + `mise.devcontainer.toml` when the profile is active.

## Host config mounts

Mount two host configs read-only into the container:

```yaml
volumes:
  - ${XDG_CONFIG_HOME:-~/.config}/mise/config.toml:/root/.config/mise/config.toml:ro
  - ~/.claude:/root/.claude
```

- **mise config**: inherits developer's global mise settings (trusted plugins, global overrides). `:-~/.config` falls back when `XDG_CONFIG_HOME` is unset.
- **~/.claude**: mounts Claude Code settings, memory, and skills so Claude Code works inside the container with the developer's full context. Mount read-write (not `:ro`) since Claude Code writes transcripts and memory.

## Auto-starting the Rails server on container connect

Use `postStartCommand` (runs on every connect, not just first create) with `nohup` to background the server:

```json
{
  "postStartCommand": "mkdir -p .devcontainer/logs && nohup bin/rails server -b 0.0.0.0 -p 3000 > .devcontainer/logs/server.log 2>&1 &"
}
```

Add `portsAttributes` to auto-open the browser when VS Code detects the forwarded port:

```json
{
  "forwardPorts": [3000],
  "portsAttributes": {
    "3000": {
      "label": "Rails",
      "onAutoForward": "openBrowser"
    }
  }
}
```

## Log paths: use the workspace mount, not extra volumes

The workspace is already mounted at `/workspace`. Write logs to paths inside
it so they're accessible from the host with no extra volume declaration:

- **Server output** → `.devcontainer/logs/server.log` (via `postStartCommand`)
- **Rails app logs** → `log/development.log` (Rails default, already on host)

Add `.devcontainer/logs/` to `.gitignore` to avoid committing runtime logs.
No separate docker-compose volume mount needed.
