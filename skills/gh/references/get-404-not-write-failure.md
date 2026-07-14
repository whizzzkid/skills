---
class: principle
---

**Rule** — A `GET` 404 on a review-comment ID is not evidence that writes fail. After
a bot replaces its review, `GET /pulls/{n}/comments/{id}` 404s the stale `databaseId`,
but `POST /pulls/{n}/comments/{id}/replies` on that same ID still returns 201. Try the
REST `/replies` POST before falling back to GraphQL.

**Why** — A read endpoint and a write endpoint on the same ID can behave differently;
generalizing a single observed `GET` 404 to "all ops 404" strands a working reply path
and forces an unnecessary (and here, `FORBIDDEN`-failing) GraphQL fallback.

**Where** — `skills/gh/SKILL.md`, the `/replies` subresource block; the over-general
"404s for *all* ops" claim also corrected in `skills/pr-resolve/SKILL.md` Step 3.
