---
skill: wk-workflow
date: 2026-04-27
type: gap
severity: medium
---

When a repo's `CLAUDE.md`/`AGENTS.md` mandates exact-version pins, and the first CI failure has a "no version is set" / "couldn't resolve latest" / "version not found" smell, the *first* fix attempt should be a version pin — not a backend or installer change.

**What happened:** The repo's `AGENTS.md` says: "Always pin to exact versions. Never use `latest`, `stable`, `nightly`, or unpinned tags." `mise.toml` had `lychee = "latest"`. The first CI failure was `mise ERROR No version is set for shim: lychee` — a textbook "your `latest` didn't bind to anything" error. I spent multiple commits exploring `reshim`, `mise exec`, `MISE_AUTO_INSTALL`, ubi/aqua backends, and a curl bypass before pinning the version (and then to the wrong version, on top of that). The fix that actually shipped was a one-line version pin — exactly what the repo standard required up front.

**Root cause:** I read the failure as "mise's exec/shim layer is misbehaving" rather than "the repo's existing config violates a rule that turns out to matter on CI." The repo's pin-exact rule was sitting in the same `AGENTS.md` I had loaded into context; I just didn't cross-reference it with the failure surface. Project standards aren't only style preferences — they're often calibrated against the project's tooling, and CI is exactly the place violations surface.

**Suggested fix:** Phase 6 (CI fix loop) should cross-reference the failure error message against repo `CLAUDE.md`/`AGENTS.md` rules before generating fix candidates. Specific patterns to check: any "version" / "tag" / "latest" / "resolve" / "shim" / "not found" error → re-read the repo's pinning rule; any auth/credentials error → re-read the repo's env-var provenance docs. The instinct should be "the repo standards exist for a reason; check them first when CI breaks." For the `wk-workflow` skill: add a one-line cross-reference step at the top of Phase 6's fix loop.
