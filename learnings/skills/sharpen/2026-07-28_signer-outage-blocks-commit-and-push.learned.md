---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

One SSH-agent refusal blocks Step 8 item 3 *and* item 4 — diagnose it once, not twice.

**What happened:** Mid-batch, `git commit` failed with `Couldn't sign message (signer):
communication with agent failed?` after five commits had already signed successfully in
the same run. The documented recovery was followed: `ssh-add -l` listed four keys (which
the commit-gate reference already says proves nothing), one retry confirmed the failure
was persistent rather than transient, and the run stopped instead of looping. The blocked
fold was left staged and its learning deliberately un-renamed, per the
distilled-not-landed rule.

The gap surfaced at the *next* step. Step 8 item 4 says "after all commits exist, push a
single time", so pushing the five landed commits looked like an independent action worth
attempting. It failed with `Permission denied (publickey)` — a different error string
naming a different concern (auth, not signing). `ssh -T git@github.com` resolved both to
one cause: `agent refused operation`. The agent holds the keys and refuses to use them, so
signing and SSH push authentication fail from the same refusal.

**Root cause:** `references/commit-gate.md` scopes the signing-failure recovery to item 3.
Nothing states that the same agent backs item 4, so push reads as an unaffected step and
gets attempted — and its error string is unrecognizable as the same fault, inviting a
second diagnosis (credentials, remote URL, org access) of an already-diagnosed problem.

**Suggested fix:** In `references/commit-gate.md`, note that a refusing agent fails
signing *and* SSH push identically, and that `Permission denied (publickey)` immediately
after a signing failure is the same outage, not a new one. Probe once with
`ssh -T git@github.com` and report both gates blocked under a single root cause; do not
attempt the push as a workaround, and do not re-diagnose it as an access problem.
