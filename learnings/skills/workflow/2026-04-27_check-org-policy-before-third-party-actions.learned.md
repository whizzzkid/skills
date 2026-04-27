---
skill: wk:workflow
date: 2026-04-27
type: gap
severity: medium
---

Before introducing a new third-party GitHub Action to a $EMPLOYER repo's CI, verify the org allows it on the configured runner group.

**What happened:** When mise-action's lychee install failed, I switched to `lycheeverse/lychee-action` — pinned to a SHA, looked clean — and pushed. The action was blocked from running on $EMPLOYER's `$EMPLOYER-ubuntu-default` runner group by org policy, which I had no way to know in advance from the workflow file alone. The user pointed it out and I had to revert.

**Root cause:** The repo's `runs-on: group: $EMPLOYER-ubuntu-default` is the signal that this CI runs on org-managed runners, which often enforce an action allowlist. I read the value as "Ubuntu, but the $EMPLOYER-managed flavor" rather than "this runner enforces an action policy I should check." I had no fast lookup for "is this third-party action allowed at $EMPLOYER."

**Suggested fix:** When a repo uses a $EMPLOYER-managed runner group (`$EMPLOYER-ubuntu-default`, `$EMPLOYER-osx-default`, etc.), prefer first-party actions (`actions/*`), already-used actions in the same workflow set, or non-action approaches (curl install, mise) before introducing a new third-party action. If a new third-party action is the right answer, ask the user: "Does <action@SHA> need allowlisting on the $EMPLOYER runner group?" before pushing — the round-trip cost of asking is much smaller than a failed CI run plus a revert. This is a $EMPLOYER-specific rule; appropriate for the $EMPLOYER-data / wk-buildkite skills but worth surfacing in any CI fix loop running against `$EMPLOYER-*-default` groups.
