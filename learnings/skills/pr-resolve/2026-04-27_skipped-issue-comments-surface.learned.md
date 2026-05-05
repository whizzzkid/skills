---
skill: wk-pr-resolve
date: 2026-04-27
type: correction
severity: high
---

Step 3 must fetch all three PR feedback surfaces every run — issue comments
were silently skipped on a re-invocation, missing a Major description-drift
finding.

**What happened:** On a second `/wk-pr-resolve` invocation in the same
session, only the GraphQL `reviewThreads` query was run. The REST
`/issues/{n}/comments` endpoint (PR conversation surface) was not fetched.
A `{bot}` issue comment flagged three description-drift
findings — including a **Major** title/body mismatch ("block
non-allowlisted target repos" still in the title after a denylist
inversion) and an incorrect test count in the test plan. The user had
to point at the comment URL explicitly before it was addressed. Worse,
I had myself noted the title was stale earlier in the session and
offered to fix it as a side task — but didn't because I didn't see the
authoritative bot finding telling me to.

**Root cause:** The skill body explicitly documents three surfaces
(inline review comments, review summary bodies, issue comments) and
says "Fetch all three every run." On the re-invocation, I took a
shortcut — assumed the only new feedback would be on review threads
because that's where the previous round's findings landed, and skipped
the issue-comments call. Compounded by: I had visual confirmation that
the title was stale but treated my own observation as lower-priority
than waiting for a reviewer to flag it; that priority was inverted.

**Suggested fix:**

1. **Pre-flight check at Step 3 entry:** before any thread analysis,
   confirm all three surfaces have been fetched in the current
   invocation — not relying on prior runs' state. Make the three
   fetches explicit (`inline_comments_fetched`, `review_bodies_fetched`,
   `issue_comments_fetched`) and refuse to proceed to Step 4 until all
   three are true.

2. **Re-invocation discipline:** when the skill is re-invoked in the
   same session, treat it as a fresh run for fetching purposes. Cached
   results from earlier in the session do NOT carry over — issue
   comments and review summaries can appear at any time, including
   between invocations.

3. **Self-noticed drift is first-class feedback:** if the agent itself
   spots a stale title, body, or count during Step 1 or Step 3, treat
   that observation as an active item to triage in this run (not a
   side-offer to the user). Add a synthetic `surface: agent_observation`
   item to the comment map with the agent as the "reviewer." The
   triage flow handles it the same as any other finding — present, get
   user decision, fix.

The third point matters because the agent often sees drift before
bots do (Step 1 reads the PR title and body; Step 3 reads file
contents). Deferring those observations to "after the bot review
catches up" is strictly worse than acting on them in the same run.
