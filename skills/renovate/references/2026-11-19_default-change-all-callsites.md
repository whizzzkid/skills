---
class: principle
source: learnings/skills/renovate/2026-11-19_default-change-all-callsites.learned.md
date: 2026-11-19
skill: wk-renovate
---

**Rule** — For every default-behavior change a bump introduces, grep every construction site of the changed type or
builder across the whole workspace and list each in the audit section with its fix or justification. For
network-client defaults (retries, timeouts, endpoint parsing), time a run on base vs head with the endpoint unreachable
and with an invalid endpoint value. A pre-1.0 minor bump (`0.x` → `0.y`) counts as a major.

**Why** — A pre-1.0 exporter release turned retries on by default. The fix landed only at the caller being edited;
sibling binaries built the same client, so a synchronous export blocked per span and a batch flush blocked at exit,
slowing every command when no collector listened. The same release turned an invalid endpoint value into a build
error that an unchecked unwrap made a startup panic. Tests stayed green because none run against an unreachable or
malformed endpoint.

**Classification** — `partial`: the default-behavior audit (installed 2026-10-23) said "check the app's use of ...
defaults it relies on implicitly" but never required enumerating every call site or exercising the failure-mode
default at runtime.

**Also observed (one-off)**

- A patch release can raise the minimum supported toolchain version, which explains a standalone Dependabot PR that
  fails CI; bump the toolchain pin in the combined PR and check repo history for precedent.
- A crate-scoped test run (`cargo test -p <crate>`) does not enable that crate's feature-gated test utilities for its
  own integration tests; a workspace-wide run hides this through feature unification. Run the crate-scoped command for
  new integration tests.

**Where** — `SKILL.md` → Step 4 (HARD RULE: audit every major-version change, per-default-change bullet); PR body
template → major-bump audit section; README Key Rules.
