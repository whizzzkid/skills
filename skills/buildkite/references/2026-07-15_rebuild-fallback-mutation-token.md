---
class: principle
---

**Rule** — When `bk job retry <id>` fails with "This API access token only allows
GraphQL queries. Mutation operations are not allowed.", do NOT treat it as a full
auth failure. Try `bk build rebuild <build-number> -p <pipeline> -y` first — it may
succeed via a different endpoint with the same token. Escalate to `bk auth login`
only if the rebuild also fails.

**Why** — A GraphQL-scoped token still has read access and can drive some write
paths. The build-level rebuild uses a different underlying endpoint than job-level
retry, so a mutation-restricted token can block the latter while permitting the
former. Treating the mutation error as a bare 401/403 stops-immediately and forces
an unnecessary re-auth.

**Where** — wk-buildkite, "Retrying a failed build" section; carve-out bullet in
"Auth Error Handling" and a row in the quick-reference table.
