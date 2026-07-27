---
skill: wk-gh
date: 2026-07-27
type: surprise
severity: low
verified-against-source: yes
---

`gh api .../pulls/{n}/reviews` POST can return a 200 whose JSON body a strict parser rejects, even though the review was created successfully.

**What happened:** Posted a pending-review payload (body + one inline comment) via `gh api repos/{owner}/{repo}/pulls/{n}/reviews --method POST --input -`. The command succeeded, but piping the response through a strict JSON parser (Python's `json.load`) raised `Invalid control character` and looked like a failure. Re-running the same POST then correctly 422'd with "User can only have one pending review per pull request" — proof the first call had actually created the review. Querying `GET .../pulls/{n}/reviews` and filtering `state == "PENDING"` confirmed it existed with the right body and inline comment.

**Root cause:** GitHub's review-create response can include raw control characters inside a string field (e.g. an embedded newline that wasn't escaped the way a strict decoder expects). This is a response-parsing quirk, not evidence the write failed.

**Suggested fix:** After any `pulls/{n}/reviews` POST, don't trust a client-side JSON parse failure as the success signal. Capture the HTTP exit code separately from the body, and on any parse error, re-query `GET .../pulls/{n}/reviews` (filter by `state` and `user.login`) to determine ground truth before treating the POST as failed or retrying it — a retry on an already-created pending review 422s.
