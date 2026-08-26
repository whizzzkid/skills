---
skill: wk-buildkite
date: 2026-08-26
type: tool-gap
severity: medium
verified-against-source: yes
---

The Buildkite CLI forwarded its bearer token to a presigned S3 artifact URL, causing S3 to reject the download for
using two authentication mechanisms. The same query-only API token could inspect builds and logs but could not retry
an infrastructure-failed job.

**Root cause:** The workflow assumes `bk artifacts download` and `bk job retry` are usable whenever Buildkite reads
succeed, but artifact redirects and mutation permissions have separate failure modes.

**Suggested fix:** When artifact download forwards auth incorrectly, request the Buildkite redirect with bearer auth
without following it, then follow the returned URL without an Authorization header. When a query-only token blocks an
infrastructure retry, use a signed empty commit to retrigger required CI only after verifying the failure occurred
before repository commands ran and the PR will squash-merge.
