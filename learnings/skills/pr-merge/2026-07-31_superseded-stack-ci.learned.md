---
skill: wk-pr-merge
date: 2026-07-31
type: gap
severity: medium
verified-against-source: yes
---

Distinguish a superseded canceled CI run from the replacement run on the same stacked-PR head.

**What happened:** Updating a stacked pull request's base branch and head branch together emitted two synchronize
events for the same final commit; concurrency canceled the first workflow while the second remained queued and
later passed.

**Root cause:** Actions run and job records confirmed that both workflow runs targeted the same head, with the older
run canceled before the queued replacement acquired runners.

**Suggested fix:** When required checks appear canceled after a stack publication, query workflow runs for the exact
head, identify the newest non-canceled run, and wait for its required jobs before blocking or merging.
