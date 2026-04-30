---
skill: wk:pr-resolve
date: 2026-04-30
type: gap
severity: medium
---

GraphQL thread resolution returns NOT_FOUND when bot replaces review during session.

**What happened:** After Step 8 push, GraphQL `resolveReviewThread` returned NOT_FOUND for all 3 thread IDs fetched in Step 3. `{bot}` replaced its review object on push, invalidating the IDs. Re-fetching threads via GraphQL gave new working IDs.

**Root cause:** Skill currently documents this pattern only for REST 404 on reply posting, not for GraphQL resolution. Step 8's resolution loop has no fallback for the bot-review-replacement case.

**Suggested fix:** Step 8 thread-resolution loop should:
1. Attempt resolution with the originally-fetched thread ID.
2. On NOT_FOUND, re-fetch all current thread IDs via GraphQL and look up by `(path, line, root_comment_databaseId)`.
3. If a matching thread is found, retry resolution with the new ID.
4. If no match, log and continue.

Also: a push during resolve commonly triggers a fresh bot review with **duplicate findings** for issues already fixed earlier in the same session. The skill has no classification for "already addressed by commit X in this session" — closest fit is dismiss but that mislabels valid findings. Consider a (p) "Point at existing commit" option.
