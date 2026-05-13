---
date: 2026-05-13
slug: toolchain-version-mismatch
---

- **Rule:** Prefix every invocation of a mise-managed tool with `mise exec --` in any repo whose `.mise.toml` pins that tool — not just when a command fails.
- **Why:** When the system binary is newer than the pinned version, the tool runs but emits version-mismatch errors (e.g., Go stdlib `compile: version "X" does not match go tool version "Y"`) that masquerade as project bugs.
- **Where:** "Diagnosing Toolchain Version Mismatch (silent failure)" sub-section between "Diagnosing Command Not Found" and "Running Commands with Mise Context".
