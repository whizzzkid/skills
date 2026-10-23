---
skill: wk-pr-review
date: 2026-10-23
type: pattern
severity: medium
verified-against-source: n/a
---

When a diff edits a shared reference file that cites a rule by number, check the number in every file that includes it.

**What happened:** A prompt-only PR added "rule 6 can still drop..." to a reference doc that two validator prompts include. In one validator, criterion 6 was the merge-bar check. In the other, it was the duplicate check. The diff didn't show the mismatch; grepping for files that include the reference found it.

**Root cause:** Numbered cross-references in shared includes resolve differently for each consumer. Reviewing against only the primary consumer misses this.

**Suggested fix:** In functional review, when a changed file is included or referenced by others (grep the path), check each numbered or named rule reference against every consumer.
