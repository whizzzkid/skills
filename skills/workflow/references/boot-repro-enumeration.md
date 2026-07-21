---
class: principle
---

# Enumerate full-boot config dependencies upfront

**Rule** — Before reproducing a full app boot that resolves config/secrets
through a resolver layer, read the config schema and the repo's existing
env-override (dev-container / compose) file to enumerate every required key in
one pass; inject them together and boot once. Reuse the env-override convention
rather than editing a generated "DO NOT EDIT" file. A trial-and-error boot loop
(boot → read the missing-key error → add → re-boot) is the signal to stop and
read the schema.

**Why** — Discovering keys one boot-failure at a time is slow trial-and-error
the user should not have to watch, and it is not a repeatable local setup.
Reading the schema lists the whole required-key set before the first attempt.

**Where** — `wk-workflow` Phase 2 niche-standards pointer →
`references/code-standards-extended.md` (full-boot config-dependency
enumeration).
