---
class: principle
---

# Plain-compose fallback hides the stack from `devcontainer exec`

**Rule** — Treat plain `docker compose up` as a last resort when `devcontainer up` fails at the build, never as an
equivalent. Before falling back, check whether any hook or script reaches the container through `devcontainer exec`;
if one does, fix the build instead. Set the bake entitlement opt-out in the CLI's own process env
(`BUILDX_BAKE_ENTITLEMENTS_FS=0 devcontainer up --workspace-folder .`). Prepare a Rails test DB with CI's recipe or
`db:test:prepare`, never `db:prepare` under the test env.

**Why**

- `devcontainer exec` resolves its target by `--container-id`, `--id-label`, or the `devcontainer.local_folder` /
  `devcontainer.config_file` labels that only `devcontainer up` applies (verified in the CLI's container-lookup code).
  A plain-compose stack carries none of them, so the stack runs while every `exec`-based hook fails to find it.
- buildx names `BUILDX_BAKE_ENTITLEMENTS_FS=0` as its opt-out for bake filesystem entitlement checks. Setting it on the
  CLI invocation worked in a run where the fallback had also been tried. `devcontainer.json` env keys never reach the
  host-side build.
- ActiveRecord's `prepare_all` loads seeds whenever it initializes a database whose config has `seeds?` set, which
  defaults to true for the primary config in every environment. `db:test:prepare` purges and loads the schema without
  seeding.

**Rejected suggestion** — None. The earlier fallback instruction was incomplete rather than wrong, so it is now
qualified instead of removed.

**Where** — `SKILL.md` → *`devcontainer up` fails at the image build*, plus the matching *Common Mistakes* rows.
