---
skill: wk-docker
date: 2026-06-12
type: surprise
severity: high
---

A Buildkite agent volume mount overlays the Docker image — Dockerfile COPY instructions to the same path are invisible at runtime.

**What happened:** A CI `go test` step failed because a gitignored embed directory (required by `//go:embed`) was absent. The fix added `COPY --from=go-build ... /src/<tool>/<embed-dir>` to the Dockerfile's final stage. The step still failed. Root cause: the Buildkite agent mounts the live checkout via `-v <checkout>:/workdir` with `--workdir=/workdir`. This bind mount completely overlays the image's `/src`, so any `COPY` to `/src/...` is unreachable for steps that run against `/workdir`.

**Root cause:** Bind mounts shadow image content at the mount point. Dockerfile `COPY` instructions write to the image filesystem; the runtime `--workdir` mount replaces it with the live checkout. The fix belongs in the step command, not the Dockerfile.

**Suggested fix:** When a CI step uses `--workdir=<mount>` (volume overlay), generated artifacts must be produced by the step's own command, not pre-baked into the image via `COPY`. For Go embeds: add `go generate ./...` to the step command before `go test`. Never rely on a `COPY` to `/src/...` reaching a step that overlays `/src` with a bind mount.
