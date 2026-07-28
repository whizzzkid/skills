---
skill: wk-docker
date: 2026-07-28
type: pattern
severity: medium
verified-against-source: yes
---

An expired package-registry credential is not a hard stop for a fresh dev container — seed its dependency volume from a sibling container's volume and install offline.

**What happened:** A newly created dev container had an empty named volume for its language dependency bundle, and the provisioning script failed at install time because the host's private-registry API key had expired (the registry returned 401 for the index fetch, confirmed with a direct authenticated request). Another worktree's container on the same host already had a fully populated volume for the same lockfile generation.

**Root cause:** The provision script treats the registry as the only source for dependencies, so any credential expiry blocks container setup entirely — even when every needed artifact is already present in another volume on the same daemon.

**Suggested fix:** Add a volume-seeding recipe. Copy between named volumes with a throwaway container mounting both, then install from the local cache only:

```bash
docker run --rm -v "$SRC_VOL":/from -v "$DST_VOL":/to alpine:3.21 \
  sh -c 'cp -a /from/. /to/ && du -sh /to'
# then, inside the container, resolve entirely from the seeded cache:
bundle install --local     # or the ecosystem's offline/frozen-cache equivalent
```

Two guards: the source volume must come from the same lockfile generation, or the offline install fails on a missing version; and volume names are project-prefixed (`<project>_<volume>`), so confirm both endpoints with `docker volume ls` before copying — a mistyped destination silently creates a new empty volume and the copy "succeeds" into nothing.
