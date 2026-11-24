---
skill: wk-pr-review
date: 2026-11-24
type: surprise
severity: low
verified-against-source: n/a
---

A "full suite: N tests" claim can span several test directories; one directory's run undercounts.

**What happened:** Replaying the claimed plugin test count by running the hook test dir gave fewer tests than claimed;
a second test dir elsewhere in the plugin held the remainder, and the sum matched exactly.

**Root cause:** The claim's scope ("full plugin run") was broader than the directory picked for the replay.

**Suggested fix:** Before marking a test-count claim Refuted, enumerate every test file under the claimed scope
(`find <scope> -name '*.<ext>'`) and count cases statically; mismatch on a partial run is not refutation.
