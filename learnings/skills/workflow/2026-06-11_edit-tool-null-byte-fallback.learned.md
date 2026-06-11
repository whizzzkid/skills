---
skill: wk-workflow
date: 2026-06-11
type: surprise
severity: medium
---

The Edit tool cannot write null bytes in replacement strings; use Python `bytes.replace()` for binary-exact replacements.

**What happened:** A duplicate-detection key used a null byte (`\x00`) as separator. The Edit tool silently failed to preserve the null byte when it was included in the replacement string, requiring a Python `bytes.replace()` workaround.

**Root cause:** The Edit tool encodes replacement content as a UTF-8 string before writing; null bytes are dropped or cause encoding errors at the boundary.

**Suggested fix:** When a file edit requires inserting literal null bytes (or other non-UTF-8 byte sequences), use Python: `open(path,'rb').read().replace(b'old', b'new')` and write back. Never attempt to pass `\x00` directly through the Edit tool's `new_string` parameter — it will silently produce a wrong result.
