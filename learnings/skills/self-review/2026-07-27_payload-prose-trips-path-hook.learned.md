---
skill: wk-self-review
date: 2026-07-27
type: gap
severity: medium
verified-against-source: no
---

Review-comment prose can trip a path-scanning pre-tool hook — build the payload with the Write tool by default, not only after a block.

**What happened:** Composing the pending review as a bash heredoc was blocked before it
ran. The offending token was not the API endpoint but a **regex literal inside one
comment body** (`/word/i.match?(…)`), which the repo's path-scope hook read as a
filesystem path outside the repo root. Re-authoring the identical JSON with the Write
tool succeeded immediately, because no bash command ever contained the string.

**Root cause:** (unverified — inferred from symptom) The hook appears to scan raw Bash
command text for path-shaped substrings and cannot distinguish a path from a slash-
delimited literal quoted inside a payload. Not confirmed by reading the hook. The
existing fallback ([blocked-post-payload-fallback]) is scoped to the endpoint-string
denial and framed as recovery *after* a block, so it does not fire here: the trigger is
different, and the guidance arrives too late to avoid the wasted attempt.

**Suggested fix:** Generalize the rule in Step 0.5 — inline review bodies are arbitrary
prose and routinely contain slashes, regex literals, and code snippets, any of which a
text-scanning hook may read as a path. Author the payload file with the Write tool as
the **default** path, not the fallback, and use bash only for the `gh api … --input
<file>` call, whose command text contains no user prose.
