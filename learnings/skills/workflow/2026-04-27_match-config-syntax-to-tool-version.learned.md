---
skill: wk-workflow
date: 2026-04-27
type: pattern
severity: low
---

When changing the version of a tool in CI/dev tooling, also check whether config files for that tool need a syntax update — and revert config changes if you later revert the version.

**What happened:** I bumped lychee from the working "latest" (which had been resolving to 0.23.x) up to 0.24.1, hit a config-parser error (`include_fragments = true` → "wanted string or table"), changed `.lychee.toml` to `include_fragments = "full"` to match 0.24.1, then later pinned back to 0.23.0 to fix unrelated install issues — but left the 0.24.1 config syntax in place. The boolean syntax was reintroduced by the user.

**Root cause:** Tool config and tool version are coupled, but I was treating them as independent. When I reverted the version, I didn't revert the config syntax in the same commit. The version downgrade fix was correct; the config diff that piggy-backed on it became incorrect.

**Suggested fix:** When changing a tool's version, list the config files that tool reads (`.lychee.toml`, `.rubocop.yml`, `tsconfig.json`, etc.) and treat them as a coupled set: any version change should be accompanied by a quick check of those configs against the new version's docs. When *reverting* a version, also revert any config changes made for the abandoned version — unless the new syntax is forwards-compatible. A one-line check ("did I change config files for this version?") at version-revert time catches this.
