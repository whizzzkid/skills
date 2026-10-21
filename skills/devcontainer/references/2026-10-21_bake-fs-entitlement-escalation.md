---
class: principle
---

# Bake fs-entitlement fix re-violated: escalate to `**Important:**`

**Rule** — On `additional privileges requested: pass "--allow=fs.read=..."` from `devcontainer up`, go straight to
`BUILDX_BAKE_ENTITLEMENTS_FS=0 devcontainer up --workspace-folder .`. Never spend a retry on `COMPOSE_BAKE=false`
first.

**Why**

- Third report of this incident (2026-10-14, 2026-10-19, 2026-10-21). The mapping had shipped in `SKILL.md` before the
  third run, and the run still tried `COMPOSE_BAKE=false` first, which the rule already says does not help. It
  re-violated an installed rule with no same-session evidence that the rule fired, so the bullet moves up one rung
  (baseline prose → `**Important:**`) per the sharpen escalation ladder.
- Re-verified: the local buildx plugin binary carries the string "To disable filesystem entitlements checks, you can
  set BUILDX_BAKE_ENTITLEMENTS_FS=0".

**Escalation record** — rung 1 → rung 2 (`**Important:**`). The next re-violation goes to `**Very important:**`.

**Where** — `SKILL.md` → *`devcontainer up` fails at the image build*, the fs-entitlement bullet.
