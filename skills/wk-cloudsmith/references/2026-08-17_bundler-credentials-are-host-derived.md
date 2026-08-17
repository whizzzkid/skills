---
class: principle
---

# Bundler credentials are derived from the source hostname, not vendor-named

**Rule** — Bundler reads gem-source credentials from `BUNDLE_<HOST>`, where the
host's periods become two underscores and the whole thing is uppercased. Host
`dl.cloudsmith.io` → `BUNDLE_DL__CLOUDSMITH__IO`, value `USERNAME:PASSWORD`
(Cloudsmith's username is the literal `token`). A vendor-named variable such as
`CLOUDSMITH_API_KEY` is never consulted.

**Why** — The failing run exported the vendor-named variable and got a registry
401, which reads as an authentication problem rather than a naming one: the
credential was correct and simply never looked at. Deriving the variable from the
Gemfile's `source` host is the check that distinguishes the two.

**Verification** — Confirmed against Bundler's own documentation rather than the
one observed token: *"Any periods in the configuration keys must be replaced with
two underscores when setting it via environment variables"* (`local.rack` →
`BUNDLE_LOCAL__RACK`), and the credentials form
`bundle config set --global SOURCE_HOSTNAME USERNAME:PASSWORD`. Recording the
transformation rule, not just the instance, so a vanity or org-specific host
resolves correctly.

**Where** — `skills/wk-cloudsmith/SKILL.md` → new section before *Org and repo
naming*; cross-referenced from the devcontainer skill's mistake table, since that
is where the 401 is observed.

## Why the manual-container case is called out

A project's provisioning script exports this variable, so the project's own
tooling works and a **manually started** container fails at the same command.
That asymmetry is the reported symptom, and it makes "read the provisioning script
for the exact name" the cheaper move than reconstructing the name by rule.
