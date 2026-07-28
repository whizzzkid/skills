---
class: principle
---

# One agent refusal blocks both the commit gate and the push gate

**Rule** — over an SSH remote, commit signing and push authentication draw on the same
ssh-agent, so a refusing agent fails Step 8 item 3 and item 4 together. Diagnose once
with `ssh -T git@<host>`; `agent refused operation` resolves both symptoms to one
cause. Report both gates blocked under that single root cause. Never attempt the push
as a workaround for a blocked commit, and never re-diagnose the push failure as an
access problem.

**Why** — the signing-failure recovery was scoped to item 3 alone, and nothing stated
that the same agent backs item 4. Push therefore read as an independent step still
worth attempting after five commits had landed. It failed with `Permission denied
(publickey)` — a different error string naming a different concern — which invites a
second, wasted diagnosis of credentials, remote URL, or org access for an
already-diagnosed fault.

**Verified** — this repo's `origin` is an SSH remote (`git@…`), and the agent-held
signing key is the same key that authenticates the push, so the coupling is real here
rather than inferred from the report. An HTTPS remote with a credential helper would
not share the fault; the rule is scoped to SSH remotes for that reason.

**Where** — `skills/sharpen/references/commit-gate.md` → *Signing failure*; the
coupling is also stated inline at `SKILL.md` Step 8 item 4, since an item-4 reader who
never reads item 3's recovery is exactly who attempts the push.
