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
  version: "2026.10.31-003026"
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
- DB adapter in `Gemfile`: `trilogy` → no `libmysqlclient-dev` needed; `mysql2` → needs it.

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
project `<workspace-folder-basename>_devcontainer`, **lowercased** (Compose rejects uppercase
project names, so an unlowered `-p` fails on a mixed-case worktree directory). A bare `docker compose -f
.devcontainer/docker-compose.yml down` defaults the project to the compose
file's parent-directory basename (`devcontainer`) → targets an empty project and
silently leaves the real stack running.

```bash
proj="$(basename "$PWD" | tr '[:upper:]' '[:lower:]')_devcontainer"
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
proj="$(basename "$PWD" | tr '[:upper:]' '[:lower:]')_devcontainer"
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
  worktree and lands an unrelated diff. Never stop the other worktree's stack.

**Important — hooks or scripts call `devcontainer exec` → the throwaway container is not enough.** Grep them first.
`devcontainer exec` finds its container only by the `devcontainer.local_folder` + `devcontainer.config_file` labels
(exact path match off Windows), which neither a throwaway nor a hand-started compose container carries — hooks then
fail with "Dev container not found". Start this worktree's own stack with an **uncommitted** override, kept outside
the tree, that resets every published port and stamps both labels:

```yaml
services:
  <service>:                 # devcontainer.json "service"; reset ports on every service that publishes one
    ports: !reset []
    labels:
      devcontainer.local_folder: <absolute workspace path>
      devcontainer.config_file: <absolute workspace path>/.devcontainer/devcontainer.json
```

```bash
docker compose -p "$proj" -f .devcontainer/docker-compose.yml -f <override.yml> up -d
```

- Then run the `postCreateCommand` steps by hand (only `devcontainer up` runs them) and prove the lookup with
  `devcontainer exec --workspace-folder . true` before relying on any hook.
- Features declared → plain compose never applies the CLI's features overlay; confirm the tools the hooks need exist in
  the container before trusting a hook's result.

## `devcontainer up` fails at the image build

**HARD RULE: surface the real build error before changing config.** The CLI reports only
"An error occurred building the Docker Compose images"; never guess from that line.

- Rerun with `devcontainer up --log-level trace` (capture under the credential rule above) and grep the capture for
  `privileges` / `error`, or rerun the generated compose overlay command from the trace by hand.
- **Important:** `additional privileges requested: pass "--allow=fs.read=<tmp>/Dockerfile-with-features"` → Compose
  5.x builds via buildx bake, which gates reads outside the build context; the CLI writes its features Dockerfile to a
  temp dir. `COMPOSE_BAKE=false` does not help — never try it first. Set `BUILDX_BAKE_ENTITLEMENTS_FS=0` (buildx's
  documented opt-out) in the CLI's own process env and retry:
  `BUILDX_BAKE_ENTITLEMENTS_FS=0 devcontainer up --workspace-folder .` (`devcontainer.json` env keys reach the
  container, never the host-side build).
- **Plain compose is a last resort, never a substitute.** `devcontainer exec` resolves its container by the
  `devcontainer.local_folder` / `devcontainer.config_file` labels only `devcontainer up` sets, so a stack started by
  plain compose is invisible to it — and to every git hook or script that shells in through it. Grep hooks and scripts
  for `devcontainer exec` first; any hit → fix the build, never fall back.
- Still failing, no features declared (the overlay adds nothing), and nothing relies on `devcontainer exec` → bring
  the stack up with plain `docker compose -p "$proj" -f .devcontainer/docker-compose.yml up -d`, run the
  `postCreateCommand` script by hand, and enter via `docker compose -p "$proj" exec` or
  `devcontainer exec --container-id <id>`.

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
| `down` reports success but containers stay up | Teardown used bare `-f` with no `-p` → empty/wrong project | Pin `-p` to the lowercased `<basename>_devcontainer` to match `devcontainer up`/VS Code |
| Startup output contains a host credential | CLI printed the interpolated Compose model | Use file-backed secrets, or capture under `umask 077` and print only an exact-value-redacted copy |
| `port is already allocated` bringing the stack up | A sibling worktree's stack of the same project already publishes that host port | Attach a throwaway container to the running stack's network and volumes with nothing published; hooks use `devcontainer exec` → ports-reset + labels override instead — *Host port already bound by a sibling worktree* |
| `bundle install` 401s in a manually-started container | Bundler credentials come from a hostname-derived `BUNDLE_<HOST>` var the provisioning script exports; a manual `docker run` does not inherit it | Export it explicitly (`wk-cloudsmith` → *Bundler credentials for a Cloudsmith gem source*) |
| `devcontainer up` fails "building the Docker Compose images" while a plain base build succeeds | Compose bake requests an fs entitlement for the CLI's temp features Dockerfile | Trace-log the real error, prefix `BUILDX_BAKE_ENTITLEMENTS_FS=0` on the CLI call; plain compose only when nothing uses `devcontainer exec` — *`devcontainer up` fails at the image build* |
| `devcontainer exec` finds no container; hooks that shell into it fail | Stack was started by plain `docker compose`, which never sets the CLI's `devcontainer.local_folder` / `config_file` labels | Fix the build and bring it up via `devcontainer up`; port clash only: stamp both labels in a compose override; ad hoc only: `devcontainer exec --container-id <id>` |
| Test counts / uniqueness fail on a freshly prepared test DB | `RAILS_ENV=test bin/rails db:prepare` runs `db/seeds.rb` whenever it initializes a DB (seeding defaults on for the primary config in every env) | Mirror CI's test-DB recipe (e.g. `db:drop db:create db:migrate`) or `bin/rails db:test:prepare` (purge + schema load, no seeds) |

## Post-Completion

Invoke `wk-learn devcontainer`.
