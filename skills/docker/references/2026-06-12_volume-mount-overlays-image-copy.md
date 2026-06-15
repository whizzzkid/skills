---
class: principle
date: 2026-06-12
---

# Bind-mount overlay shadows image COPY

**Rule:** When a CI step runs under a volume mount (`-v <checkout>:/workdir
--workdir=/workdir`), generated artifacts that step needs must be produced by the
step's own command, never pre-baked into the image via `COPY` to a path under the
mount.

**Why:** A runtime bind mount replaces the image filesystem at the mount point
with the live checkout, so any Dockerfile `COPY` to that path is unreachable. A
`COPY --from=...` of a Go embed dir lands in the image yet the mounted `go test`
step still reports it missing — the fix belongs in the step command
(`go generate ./...`), not the Dockerfile.

**Where:** "Bind-Mount Overlay Shadows Image COPY" section.
