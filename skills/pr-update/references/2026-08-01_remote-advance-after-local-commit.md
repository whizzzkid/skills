---
class: principle
---

# Preserve remote history after a local integration commit

**Rule** — A non-fast-forward normal push after merge integration requires a
fetch, remote-only commit inspection against the fetched SHA, merge of that
exact SHA, full re-validation, and another normal push.

**Why** — The remote branch can advance after the base was fetched and the local
integration commit was created. Force-pushing or retrying from stale state drops
one history; reusing pre-merge validation leaves the combined tree unverified.

**Where** — `SKILL.md` Stage 6 and the README strategy/push flow.
