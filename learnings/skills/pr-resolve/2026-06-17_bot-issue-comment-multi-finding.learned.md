---
skill: wk-pr-resolve
date: 2026-06-17
type: gap
severity: low
---

A single bot issue comment may contain multiple distinct findings — one reply handles all

**What happened:** A bot's PR-level issue comment contained two separate findings:
a missing section in the PR description and a stale doc comment in an out-of-diff file.
These were presented as separate findings in the comment body but originated from the
same `issues/{n}/comments` entry with a single ID.

**Root cause:** The skill's comment map treats each issue comment as one triage unit.
When a bot bundles multiple concerns into one issue comment (common for "findings outside
the diff" summaries), the triage step must split them into separate suggestions while
the reply step recombines them into a single post (you cannot reply to sub-sections of
an issue comment).

**Suggested fix:** In Step 3, when parsing bot issue comments, scan for multiple
heading-separated or bullet-separated findings within a single comment body and generate
one suggestion per finding. In Step 8, collapse all accepted findings from the same
source comment into a single reply so there is no double-posting.
