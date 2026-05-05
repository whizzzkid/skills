---
skill: wk-workflow
date: 2026-04-27
type: correction
severity: high
---

When the user's preferred tool stack fails on a new dependency version, downgrade the dependency before bypassing the tool stack.

**What happened:** While fixing a CI link-check workflow, mise's default registry/aqua/ubi backends all failed to make `lychee 0.24.1` runnable via `mise exec`. After ~6 failing CI iterations, I bypassed mise entirely with a direct `curl | tar` install from GitHub Releases — re-implementing tarball extraction, binary location, and version pinning in the workflow itself. The user reverted the whole thing with a one-line change: `lychee = "0.23.0"` in `mise.toml`. The previous version worked under mise's default backend with no install args gymnastics, no `mise exec`, no `MISE_AUTO_INSTALL`, no `.lychee.toml` syntax updates.

**Root cause:** I treated the failing dependency version as a fixed input and the user's tool choice (mise-action) as the variable. The cheaper move — try a version that the user's existing tooling already handles — was never on my shortlist. I also kept escalating fixes (default → ubi → aqua → curl) instead of stepping back to ask "is this the right axis to vary?". Each escalation widened the diff (`.lychee.toml` syntax change, `LYCHEE_VERSION` env, `find` heuristics, `sudo install` step) and added rollback debt the user then had to undo.

**Suggested fix:** Add an explicit step to the workflow's CI fix loop guidance: when a dependency upgrade is the proximate cause of a failure, try downgrading that dependency by one or two minor/patch versions before changing build/install machinery, switching backends, or bypassing the user's preferred tool. Two-version-down beats N-tool-changes-deep almost every time, and it preserves the rest of the user's setup. The "minimal targeted fix" rule in Phase 6 should explicitly include "smallest version regression" as a candidate fix, not just "smallest code change."
