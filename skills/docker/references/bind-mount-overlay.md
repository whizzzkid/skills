# Bind-Mount Overlay Shadows Image COPY

A CI step that runs under a volume mount (`-v <checkout>:/workdir --workdir=/workdir`, common on Buildkite agents) replaces the image filesystem at the mount point with the live checkout. Any Dockerfile `COPY` to a path under that mount is invisible at runtime.

**HARD RULE:** Generated artifacts a mounted step needs (Go embeds, codegen, build output) must be produced by the step's own command, not pre-baked via `COPY` into the overlaid path.

- Symptom: a `COPY --from=...` lands in the image, yet the step still reports the file missing.
- Fix: add the generator to the step command before the consumer — e.g. `go generate ./... && go test`.
- Never rely on `COPY /workdir/...` (or any mount-point path) reaching a step that overlays that path with a bind mount.
