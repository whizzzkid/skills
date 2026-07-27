---
skill: wk-gh
class: principle
---

**Rule** — After a `POST /pulls/{n}/reviews`, a client-side JSON parse failure is not
evidence the write failed. Capture the HTTP status separately from the body; on any parse
error, re-query `GET /pulls/{n}/reviews` filtered by `state` and `user.login` to establish
ground truth before retrying.

**Why** — GitHub's review-create response can carry an unescaped control character inside a
string field, which a strict decoder rejects even though the review was created. Treating
the parse error as a failure and retrying produces a 422
(`User can only have one pending review per pull request`) — which reads as a second,
unrelated bug and sends the run down the wrong branch. The 422 on retry is in fact the proof
that the first POST succeeded.

**Verified** — The parser half was reproduced locally: `json.loads` on a JSON string field
containing a raw newline raises exactly the reported `Invalid control character`, while
`json.loads(..., strict=False)` parses the same bytes and yields the correct fields. The
server half (GitHub emitting such a body) is taken from the field report and was **not**
independently reproduced — doing so would require creating a real pending review on a live
pull request, an external side-effecting write outside the scope of a distillation run. The
remediation does not depend on the server half: re-querying before retrying is correct
whatever produced the unparseable body.

**Generalizes** — The shape is "a write succeeded but its response could not be read". The
success signal for a write is the HTTP status plus a follow-up read of server state, never
the parseability of the response body.

**Where** — wk-gh, pending-review guard list.
