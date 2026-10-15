---
class: principle
---

# `devcontainer up` build failure: bake fs entitlement

**Rule**

- When `devcontainer up` fails at the image build, get the real error from a trace log or by rerunning the generated
  overlay by hand before changing config. A bake fs-entitlement request for the CLI's temp features Dockerfile →
  export `BUILDX_BAKE_ENTITLEMENTS_FS=0` and retry; no features declared → fall back to plain compose plus the
  post-create script.

**Why**

- Two runs on 2026-10-14 (filed under both `wk-docker` and `wk-devcontainer`, one principle, one home here) hit the
  generic "error occurred building the Docker Compose images". Only the trace or a hand rerun showed
  `additional privileges requested: pass "--allow=fs.read=<tmp>/Dockerfile-with-features"`. `COMPOSE_BAKE=false` had
  no effect in either. `BUILDX_BAKE_ENTITLEMENTS_FS=0` fixed one run and not the other. The local buildx binary
  carries the hint "To disable filesystem entitlements checks, you can set BUILDX_BAKE_ENTITLEMENTS_FS=0", which
  confirms the variable is real. Why it failed in the second run is still unverified.

**Where**

`skills/devcontainer/SKILL.md` → `devcontainer up` fails at the image build; Common Mistakes row.
