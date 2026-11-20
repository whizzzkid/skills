---
skill: wk-adversarial-review
date: 2026-11-20
type: correction
severity: low
verified-against-source: yes
---

Verify environment claims before putting them in a reviewer brief.

**What happened:** The brief told reviewers that both old and new dependency versions were installed in the
container for source diffs. Several old versions were not. The reviewers noticed and fetched the missing sources,
which cost extra time.

**Root cause:** The claim came from an assumption that a container provisioned from the base lockfile keeps every
old gem after the update, without running `ls` on the gem dir.

**Suggested fix:** Before dispatch, list what is present (`ls <gem dir> | grep <names>`). State only verified facts
in the brief, and give the fetch command for whatever is missing.
