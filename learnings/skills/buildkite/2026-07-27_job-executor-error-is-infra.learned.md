---
skill: wk-buildkite
date: 2026-07-27
type: pattern
severity: medium
verified-against-source: yes
---

A red Buildkite build whose job log ends in `job_executor_error` is agent infrastructure, not the change — retry the job instead of debugging the diff.

**What happened:** A pushed commit turned the build red on the main test step. The step name (`Rails test environment`) and exit status `255` both read as a test failure, and the obvious next move was to bisect the diff. The job log instead showed the failure occurred **before any command ran**:

```
~~~ Running agent environment hook
$ /etc/buildkite-agent/hooks/environment
🚨 Error: Error setting up job executor: running "agent environment" shell hook: the agent environment hook exited with status 52
```

followed by the agent's own post-processing: `Detected failure: job_executor_error, updating command exit code to -1`. A single-job retry went green with no code change.

**Root cause:** The agent's environment hook runs before the step's command; when it fails, the job is marked failed under the step's name and a synthetic exit status, so the GitHub status and the checks list are indistinguishable from a genuine test failure. Only the log body separates them.

**Suggested fix:** Before attributing a red Buildkite build to the diff, fetch the failing job's log and classify it:

```bash
# List failing jobs on a build
curl -sS -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
  "https://api.buildkite.com/v2/organizations/$BK_ORG/pipelines/$BK_PIPELINE/builds/$N" \
| jq -r '.jobs[] | select(.state=="failed") | "\(.name)\t\(.exit_status)\t\(.id)"'

# Read its log (strip ANSI + Buildkite timestamp markers)
curl -sS -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
  ".../builds/$N/jobs/$JOB_ID/log" \
| python3 -c 'import sys,json,re; c=json.load(sys.stdin)["content"]; print(re.sub(r"\x1b\[[0-9;]*[a-zA-Z]|_bk;t=\d+","",c)[-6000:])'
```

Treat these markers as **infrastructure, retry once, do not touch the diff**:

- `Error setting up job executor`
- `job_executor_error` / `updating command exit code to -1`
- any failure inside `Running agent environment hook` / a `pre-exit` hook
- agent lost / instance terminated / unhealthy-instance indicators

Retry the single job rather than the whole build:

```bash
curl -sS -X PUT -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
  ".../builds/$N/jobs/$JOB_ID/retry" | jq -r '.state, .web_url'
```

Only after the log shows the step's command actually executed should the failure be read as a signal about the change. Note also that the JSON log payload carries ANSI escapes and `_bk;t=<epoch-ms>` timestamp markers inline — stripping both is required before the tail is readable.
