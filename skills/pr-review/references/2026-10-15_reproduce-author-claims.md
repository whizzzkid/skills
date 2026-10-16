---
class: principle
---

# Re-derive the author's cited figures from primary data

**Rule**

- Treat each figure a description cites (counts, timestamps, CI windows, "fails in env X but not Y") as a claim:
  re-derive it from primary data (CI API, logs) and rerun the author's own experiment in a scratch worktree.
- When pairing log events, match the next *result* line by pattern, never the next physical line.

**Why**

- CI timestamps and counts matched exactly, yet the rerun local experiment gave a different failure count: the code
  path named as env-gated was not gated. Once most claims check out, the rest are easy to accept unchecked.
- A logged payload spanning several lines made "the next line's timestamp" a wrong latency pairing.

**Where** — `SKILL.md` → Phase 1 → Claims bullet (cited-figures sub-bullet).
