---
class: principle
---

# Exhaust your own inputs before asking

**Rule** — Never ask the user for something the run's own inputs already answer.
Search the plan, merged PRs, and tracked config first. A question they already
answer proves they went unread.

**Why** — The ask-gate enumerated the *situations* that justify stopping (ambiguous
plan, persistent CI, user-owned design decision, requested pause, destructive
action) but stated no precondition on the *content* of a question. A value sitting
in a merged configuration PR and restated in the plan's own local-testing section
therefore passed the gate as a legitimate ask. Situational gating cannot catch
this; the missing check is about whether the answer already exists.

**Where** — `skills/workflow/SKILL.md` → immediately after the "Stop and ask only
when" enumeration, as the precondition that qualifies every entry in it.

## Deliberately not folded here

Two "What worked" practices from the same source are recorded rather than folded:

- **Re-merging a branch whose stacked parents squash-landed** — taking `--theirs`
  for files fully superseded by the squashed parent and hand-merging
  additive-on-both-sides files. This is the *resolution* half of the same scenario
  whose *detection* half is the corrective lesson in the next retrospect
  (`pr-update`: independently-merged parents). Folding it here would edit the same
  pr-update section twice in one drain; it belongs with the detection rule.
- **Validating an OIDC integration without real credentials** — the framework's
  dev-login shortcut plus a discovery-URL probe that fails at DNS proved app-side
  wiring. Judged `one-off`: the technique is specific to a provider-discovery
  handshake and does not generalize into a rule worth carrying at runtime.
