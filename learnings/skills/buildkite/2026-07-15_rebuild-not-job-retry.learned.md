---
skill: wk-buildkite
date: 2026-07-15
type: surprise
severity: low
---

Under an env-var `BUILDKITE_API_TOKEN` scoped to GraphQL-only queries, `bk job retry <id>` fails with "This API access token only allows GraphQL queries. Mutation operations are not allowed." — but `bk build rebuild <build-number> -p <pipeline> -y` succeeds with the same token and re-runs the whole build.

**What happened:** A build failed in an early infra-shaped step (a GitHub-App-token-generator plugin hook, unrelated to the diff under test — the target repo's most recent `main` build was green). Following the skill's guidance to retry, `bk job retry` was attempted first and hit the mutation-not-allowed error. `bk build rebuild` on the same build number worked and produced a clean re-run.

**Root cause:** The skill's Auth Error Handling section treats any 401/403/scope error as "stop, ask user to `bk auth login`." It doesn't distinguish a REST-mutation-blocked token (which still has read access and can drive some write paths) from a fully unauthenticated session, and doesn't mention that `bk build rebuild` may succeed via a different underlying endpoint than `bk job retry` even when the token is mutation-restricted for job-level operations.

**Suggested fix:** When `bk job retry` returns "mutation operations are not allowed" (as opposed to a bare 401/403), don't treat it as a full auth failure requiring `bk auth login` — try `bk build rebuild <build-number> -p <pipeline> -y` as a fallback before escalating to the user. Add this as an explicit fallback step in the Cancelling/Retrying section, distinct from the Auth Error Handling table's stop-immediately cases.
