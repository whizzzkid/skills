---
class: principle
skill: wk-devcontainer
date: 2026-10-30
severity: medium
---

**Rule** — On a host-port clash with a sibling worktree's stack, when hooks or scripts shell in through
`devcontainer exec`, start this worktree's own stack with an uncommitted compose override that resets every published
port (`ports: !reset []`) and stamps both `devcontainer.local_folder` and `devcontainer.config_file` labels with the
exact absolute workspace and config paths. Run the post-create steps by hand, and prove the lookup with
`devcontainer exec --workspace-folder . true` before relying on a hook. Never stop the other worktree's stack.

**Why** — `devcontainer up` built the image, then failed at compose up with "Bind for 127.0.0.1:3000 failed: port is
already allocated". A port-free hand-started stack ran tests fine, but every hook calling `devcontainer exec` failed
with "Dev container not found". Verified in the CLI's container lookup: with no `--container-id` it matches on
`devcontainer.local_folder=<workspace>` plus `devcontainer.config_file=<config>`, and normalizes paths only on Windows.
Elsewhere that is an exact string match. The existing throwaway-container remedy covers ad hoc commands but not
`devcontainer exec` callers. It extends the 2026-10-19 plain-compose label finding into the port-clash path.

**Where** — `SKILL.md` → "Host port already bound by a sibling worktree", plus the two matching Common Mistakes rows.
