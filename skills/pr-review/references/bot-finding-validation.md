# Bot Finding Validation

## Phase 4 action table (from Phase 3 outcome)

| Phase 3 outcome | Phase 4 action |
|---|---|
| **Confirmed** | Silent skip at thread and body level. |
| **Confirmed but narrower** | Reply only if the scope note cites a *new fact* (see gate below); else treat as Confirmed → silent skip. |
| **Confirmed but broader** | Reply with the amplified impact as new evidence (e.g. a referenced target that 404s). |
| **Refuted** | Reply `**Could not reproduce** — <counter-evidence>` and what was tested. |
| **Inconclusive** + agent found it | Reply with the agent's evidence and fix. |
| **Inconclusive** + agent did not | Leave the thread; surface in the summary for override. |

## Narrower/broader requires a new fact, not an opinion

The reply must cite something the bot's comment lacked — a grep result, test
run, reachability/trigger check, or amplified downstream target. A standalone
judgment about priority, blast radius, or whether it's "worth fixing now" is not
narrower; it's Confirmed → silent skip.

- Narrower: "only fires when `FOO` is set; grep shows no caller sets it" (new fact).
- Not narrower: "lower priority, same-repo producer" (opinion, no new fact) → Confirmed, silent skip.

## Per-thread reply gate

**HARD RULE:** A per-thread bot reply or body anchor is justified only with new evidence beyond
confirming the bot's exact claim. Pure Confirmed outcomes get silent skip; never
narrate bot validation. Justified replies use one mechanism: fold into the body
as `Re: {bot} thread on {file}:{line} — …` (no extra call), or a live
`/comments/{id}/replies` post (requires explicit user opt-in — it bypasses the
pending-review checkpoint). Never embed bot replies in the pending `comments[]`
payload (`in_reply_to` 422).
