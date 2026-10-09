---
name: wk-devcontainer
description: >
  Use when creating or debugging a devcontainer for a Rails app (or any
  mise-managed project) — generates Dockerfile, docker-compose.yml, and
  devcontainer.json with correct mise, Bundler, MySQL, and Redis wiring.
  Trigger phrases: "set up devcontainer", "create devcontainer", "devcontainer
  not working", "bundle install fails in devcontainer", "mise tools missing in
  container".
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.10.09-005632"
  model:
    openai: gpt-5.6-terra
---

# wk-devcontainer

Create or debug a `.devcontainer/` setup for a mise-managed Rails app.

## When to Use

- Setting up a new devcontainer from scratch
- Debugging broken mise tool resolution, Bundler cache, MySQL/Redis connectivity
- After `postCreateCommand` fails or tools are missing in the container

## Step 1: Audit the project first

**HARD RULE: Check CI compose before writing any config.** Project already
demonstrates the correct Docker override pattern.

```bash
cat .buildkite/docker/compose.yml   # authoritative for CONFIG__ overrides
cat config/database.yml             # which keys drive DB connection
cat .ruby-version                   # pin this exactly in mise.toml
grep -E "redis|sidekiq|elasticsearch" Gemfile | head -10  # extra services needed
```

- Read all four.
- CI compose → exact image versions, service names, `CONFIG__` keys. Copy them, don't guess.

## Steps 2-4: Write the config files

See [references/config-templates.md](references/config-templates.md) for
complete Dockerfile, docker-compose.yml, and devcontainer.json templates with
key decisions and HARD RULEs (no manual PATH/shim wiring, no COPY mise.toml,
no env var the app conditionally defaults).

**HARD RULE: Never stream `devcontainer up` output when Compose interpolates a
host credential** — some CLI versions print the resolved Compose model. Enumerate
host vars Compose references first; prefer file-backed secrets; else `umask 077`,
capture output to a temp file, show only an exact-value-redacted copy, delete the raw
capture on exit, and prove it with a canary. Direct startup with a forwarded
credential is a blocker.

**Mise profiles (optional):** keep host `mise.toml` lean; add container-only
tools via `mise.devcontainer.toml` + `MISE_PROFILE: devcontainer` in compose.

## Step 5: Update mise.toml

Add to the project's `mise.toml`:

```toml
[settings]
auto_install = true   # install tools on container start, no COPY+install at build time

[tools]
ruby = "3.4.7"   # must match .ruby-version exactly
```

Ruby version must match `.ruby-version` exactly → mismatch causes Bundler
lockfile platform conflicts.

## Teardown / rebuild the stack

**HARD RULE: pin the Compose project name in every teardown/rebuild command.**
`devcontainer up` and VS Code "Reopen in Container" create the stack under
project `<workspace-folder-basename>_devcontainer`. A bare `docker compose -f
.devcontainer/docker-compose.yml down` defaults the project to the compose
file's parent-directory basename (`devcontainer`) → targets an empty project and
silently leaves the real stack running.

```bash
proj="$(basename "$PWD")_devcontainer"
docker compose -p "$proj" ps                                          # verify target before acting
docker compose -p "$proj" -f .devcontainer/docker-compose.yml down    # stop (add -v to drop volumes)
docker compose -p "$proj" -f .devcontainer/docker-compose.yml build   # rebuild
```

### Host port already bound by a sibling worktree

Two worktrees of one project publish the same host port, so the second stack
cannot start. A published port exists only for **host** access —
container-to-container traffic uses the Compose network — so a task that merely
needs to run inside the project environment does not need one.

Attach a throwaway container to the running stack's network and named volumes,
publishing nothing:

```bash
proj="$(basename "$PWD")_devcontainer"
docker network ls; docker volume ls          # resolve real names before running
docker run --rm -it \
  --network "${proj}_default" \
  -v "${proj}_bundle:/usr/local/bundle" \
  -v "$PWD:/workspace" -w /workspace \
  <app-image> bash
```

- Read the network and volume names off the running stack; the `_default` suffix
  and volume prefixes follow the **pinned project name**, not the compose file's
  directory.
- Never resolve this by editing the committed port mapping — that breaks the other
  worktree and lands an unrelated diff.

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
| Dependency install fails on registry `401` in a fresh container | Expired package-registry credential; the provisioning script treats the registry as the only source | Not a hard stop — seed the dependency volume from a sibling container's volume on the same daemon and install offline (`wk-docker` → *Seed a Dependency Volume from a Sibling*) |
| `down` reports success but containers stay up | Teardown used bare `-f` with no `-p` → empty/wrong project | Pin `-p "$(basename "$PWD")_devcontainer"` to match `devcontainer up`/VS Code |
| Startup output contains a host credential | CLI printed the interpolated Compose model | Use file-backed secrets, or capture under `umask 077` and print only an exact-value-redacted copy |
| `port is already allocated` bringing the stack up | A sibling worktree's stack of the same project already publishes that host port | Attach a throwaway container to the running stack's network and volumes with nothing published — *Host port already bound by a sibling worktree* |
| `bundle install` 401s in a manually-started container | Bundler credentials come from a hostname-derived `BUNDLE_<HOST>` var the provisioning script exports; a manual `docker run` does not inherit it | Export it explicitly (`wk-cloudsmith` → *Bundler credentials for a Cloudsmith gem source*) |

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
5. DB adapter in `Gemfile` — `trilogy` (no `libmysqlclient-dev` needed) vs `mysql2` (needs it)

## Post-Completion

Invoke `wk-learn devcontainer`.
