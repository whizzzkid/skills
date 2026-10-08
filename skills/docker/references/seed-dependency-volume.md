# Seed a Dependency Volume from a Sibling

An expired package-registry credential is not a hard stop for a fresh container. A provisioning script typically treats the registry as the *only* source of dependencies, so a 401 on index fetch blocks setup entirely — even when every needed artifact already sits in a sibling container's volume on the same daemon.

Copy the volume with a throwaway container mounting both, then install offline:

```bash
docker volume ls          # confirm BOTH endpoints exist before copying
docker run --rm -v "$SRC_VOL":/from -v "$DST_VOL":/to alpine:3.21 \
  sh -c 'cp -a /from/. /to/ && du -sh /to'
```

Then, inside the target container, resolve entirely from the seeded cache — `bundle install --local`, or the ecosystem's offline / frozen-cache equivalent.

Two guards:

- **Seed only from the same lockfile generation.** The offline install then fails loudly on a missing version instead of silently resolving a stale one.
- **Verify both volume names before copying.** Names are project-prefixed (`<project>_<volume>`), so a mistyped destination silently creates a new empty volume and the copy "succeeds" into nothing.
