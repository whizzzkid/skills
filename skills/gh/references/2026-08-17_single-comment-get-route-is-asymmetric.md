---
class: principle
---

# The single-comment GET route is asymmetric with the reply POST

**Rule** — `GET /repos/{owner}/{repo}/pulls/comments/{id}` carries **no PR
number**; the reply is `POST /repos/{owner}/{repo}/pulls/{n}/comments/{id}/replies`.
`/pulls/{n}/comments/{id}` matches no route, so it 404s even for a live comment.

**Discriminator** — Read the 404 body, not just the status:

| `documentation_url` | meaning |
| --- | --- |
| generic (`https://docs.github.com/rest`) | no route matched — wrong path shape |
| operation-specific (`…/rest/pulls/comments#get-a-review-comment-…`) | route matched, resource missing |

**Why** — This corrects an error in the skill's own text, which is why the
existing "a `GET` 404 is not evidence writes fail" rule did not help. That rule
was installed 2026-07-14, well before the report, but it *prescribed*
`GET /pulls/{n}/comments/{id}` — a route that 404s unconditionally. An agent
following it had no way to separate "stale comment ID" from "path I cannot reach",
which is exactly the reported symptom: repeated false 404s before root-causing the
path shape.

**Where** — `skills/gh/SKILL.md` → *Prefer the `/replies` subresource over
`in_reply_to`*.

## Verification

Probed both shapes against a live repository rather than inferring from docs:

- `/pulls/comments/<id>` → 404 with `documentation_url` naming
  *get-a-review-comment-for-a-pull-request* → the route resolved.
- `/pulls/{n}/comments/<id>` → 404 with the bare `docs.github.com/rest` URL → no
  route resolved.

Both probes used an ID known not to exist, so the differing `documentation_url` is
attributable to the route shape alone.

Both return HTTP 404, so status alone cannot distinguish them; the body can.

## No escalation notch

A re-violation notch raises a rule's *volume*. Here the rule was **factually
wrong**, and correcting it strictly dominates making it louder — a louder
instruction to call an unreachable endpoint fails identically. Recorded so a later
pass does not read "installed before the report" and escalate on that basis alone.

## The source's other lesson needed no fold

The Sorbet `T.bind`-inside-`prepend` lesson from the same session was already
distilled on 2026-08-11 as a `one-off` reference under `wk-pr-resolve`, with a
recorded "why not promoted" rationale. Correctly reference-only and correctly
unlinked from `SKILL.md`; left untouched.
