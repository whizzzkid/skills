---
skill: wk-buildkite
date: 2026-06-09
type: gap
severity: medium
---

Internal registry mirrors may not be pull-through — verify the image repo exists before pinning a CI step to it.

**What happened:** A pipeline step was switched to a mirrored `library/golang` image; the build failed at `docker pull` with "repository does not exist in the registry" because the org's ECR docker-hub mirror only carries pre-seeded repositories.

**Root cause:** Assumed the mirror was a pull-through cache because other `library/*` images worked.

**Suggested fix:** Before referencing a new image path under an internal mirror, check that the exact repository exists (or reuse an image already referenced in the pipeline and install the extra toolchain into it, pinned + checksummed).
