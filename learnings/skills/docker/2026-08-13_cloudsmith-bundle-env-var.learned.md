---
skill: wk-docker
date: 2026-08-13
type: gap
severity: low
verified-against-source: yes
---

`bundle install` against a Cloudsmith-backed gem source fails even with a valid API key exported as a generic env var, because Bundler requires the key encoded into a source-specific credential var name, not a plain token var.

**What happened:** Running `bundle install` inside a manually-started container (`docker run`, not the project's own `post-create.sh` path) with `CLOUDSMITH_API_KEY` exported failed with "Authentication is required for dl.cloudsmith.io."

**Root cause:** Bundler resolves per-source HTTP Basic auth from an env var named `BUNDLE_<HOST_WITH_UNDERSCORES>` (e.g. `BUNDLE_DL__CLOUDSMITH__IO="token:<key>"`), not from an arbitrary env var holding the token — the project's own `post-create.sh` already sets this, confirmed by reading it.

**Suggested fix:** Before debugging a Cloudsmith (or any private Bundler source) auth failure inside a container started by hand rather than the project's own setup script, grep that setup script first for how it exports Bundler credentials, and replicate the exact `BUNDLE_<HOST>` env var name/format rather than assuming a plain API-key env var is sufficient.
