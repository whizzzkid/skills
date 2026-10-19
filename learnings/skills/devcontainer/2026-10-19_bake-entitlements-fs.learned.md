---
skill: wk-devcontainer
date: 2026-10-19
type: surprise
severity: medium
verified-against-source: no
---

`devcontainer up` on a compose-based devcontainer fails in buildx bake with "additional privileges requested: pass --allow=fs.read=...".

**What happened:** Build failed; `COMPOSE_BAKE=false` did not help. `BUILDX_BAKE_ENTITLEMENTS_FS=0 devcontainer up --workspace-folder .` succeeded. Falling back to plain `docker compose up` started the stack but left it invisible to `devcontainer exec` (missing devcontainer labels), breaking git hooks that shell into the container.

**Root cause:** (unverified — inferred from symptom) newer buildx enforces fs entitlements for bake, and the devcontainer CLI passes a features Dockerfile from a temp dir outside the context.

**Suggested fix:** Document `BUILDX_BAKE_ENTITLEMENTS_FS=0` as the fix; never substitute plain `docker compose up` when hooks rely on `devcontainer exec`. Also: `db:prepare` under the test env seeds the test DB → spurious count failures; recreate with `db:drop db:create db:migrate` as CI does.
