---
skill: wk-buildkite
date: 2026-05-12
type: gap
severity: high
---

When the `bk` CLI fails with auth errors, prompt the user to run `bk auth login` before attempting any API workarounds.

**What happened:** During a debugging session the `bk` CLI returned permission/auth errors when fetching build annotations. Instead of stopping, the agent tried a manual `curl` workaround using token extraction. The user interrupted and said "create a skill to deal with `bk` cli in `~/gitc/skills` and add this check there." The workaround never worked and wasted several turns.

**Root cause:** No auth-check gate at the start of `bk` usage. The agent assumed the CLI was authenticated and escalated to curl/token hacks when the assumption failed.

**Suggested fix:** Add a pre-flight auth check at the start of any `wk-buildkite` flow that calls `bk`:

```bash
if ! bk builds --help &>/dev/null; then
  echo "bk CLI not found or not authenticated. Run: bk auth login"
  exit 1
fi
```

Also check for auth specifically: if a `bk` call returns `401`/`403` or "unauthorized", stop immediately and tell the user: "bk CLI is not authenticated. Run `bk auth login` and retry." Do not attempt curl workarounds using extracted tokens.
