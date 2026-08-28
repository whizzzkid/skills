---
skill: wk-workflow
date: 2026-08-27
type: correction
severity: medium
verified-against-source: n/a
---

A "don't run {tool} locally" directive can be read as banning that tool's own repo test suite, not just the tool's product action.

**What happened:** The user had said "don't run {tool} locally" (meaning: don't invoke the tool's review/product action). While validating a fix in that tool's source repo, the agent kicked off the repo's full unit-test suite as a background job. The user re-sent "don't run {tool} locally" mid-turn, and the agent stopped the suite.

**Root cause:** The agent treated "run {tool} locally" narrowly (the product action) and assumed the repo's own `rspec`/test suite was categorically different. To the user, a heavy background run against that repo read as the banned activity — the boundary was ambiguous and never confirmed.

**Suggested fix:** When a user bans running a named tool/app locally, treat any heavy or long-running local execution against that tool's repo (full test suites, servers, build steps) as in-scope of the ban unless the user explicitly carved it out. Prefer the narrow spec (only the file(s) the change touches) and let CI run the full suite; if a full local run seems necessary, confirm scope first rather than launching it in the background.
