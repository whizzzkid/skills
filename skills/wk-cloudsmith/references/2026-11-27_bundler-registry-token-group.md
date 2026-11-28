---
class: principle
source: learnings/skills/env/2026-11-27_bundler-registry-token-group.learned.md
---

# Host Bundler auth failure: run the package-manager token group, not a personal key

**Rule** — On a host `bundle install` registry auth failure (`Bad username or password`), list the setup tool's
doctor groups, run the Bundler-specific entitlement-token group, then the install group. Never export a personal
registry API key as a `BUNDLE_*` override. Confirm the fix by the user Bundler config file's mtime moving.

**Why** — The setup tool splits registry auth into a CLI-login group and one entitlement-token group per package
manager (Bundler, npm, pip, uv, yarn). Only the per-package-manager group writes Bundler credentials, so a passing
login group leaves the Bundler config untouched (old mtime) and install still fails. A personal key exported as an
override masks the unprovisioned token and substitutes the user's identity for the project's entitlement.

**Verification** — Re-checked against the owning source, not the report: the setup tool's doctor-group listing names
a separate CLI/developer-auth group and per-package-manager "Default Entitlement Token" groups, and the user Bundler
config holds per-source-URI credential keys rewritten at the time of the fix.

**Ownership** — Filed against `wk-env`, folded into `wk-cloudsmith`: the Bundler-credential mechanics already live in
its *Bundler credentials* section, and that section's `export BUNDLE_<HOST>=token:$KEY` recipe was the over-general
instance (it reads as a host fix). The recipe is now scoped to contexts handed a minted key. `wk-env` diagnoses env
vars; this failure is a missing credential file, not an uninherited var, so it gets no edit.

**Where** — `skills/wk-cloudsmith/SKILL.md` → *Bundler credentials for a Cloudsmith gem source* (intro scope line and
last bullet).
