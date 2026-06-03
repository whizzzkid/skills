---
skill: wk-sharpen
date: 2026-06-02
type: surprise
severity: low
---

A truncated/partial Read of a large SKILL.md does not satisfy Edit's
read-before-write guard — the first Edit failed with "File has not been read yet".

**What happened:** Step 2 read a >25k-token SKILL.md, which returned a partial
view (lines 1-1327 of 1719). The frontmatter `description` was visible in that
range, but the subsequent Edit on it was rejected as unread until a second small
Read of the same region was issued.

**Root cause:** The harness tracks file-read state per actual page returned, not
per file. A partial Read leaves the file marked unread for Edit purposes.

**Suggested fix:** When Step 2's full-skill read returns a PARTIAL view on a large
file, re-Read the specific line range you intend to Edit (small `offset`/`limit`)
immediately before the Edit, rather than relying on the partial full-file read to
register the file as read.
