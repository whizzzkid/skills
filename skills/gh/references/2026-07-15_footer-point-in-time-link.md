---
class: principle
---

**Rule** — The canonical outbound footer's `wk-skills` link pins to a post-time
snapshot: `github.com/whizzzkid/skills/tree/main@%7B<UTC>%7D`, where `<UTC>` is a
render-time UTC timestamp (`date -u +%Y-%m-%dT%H:%M:%SZ`). URL-encode only the
braces (`{`→`%7B`, `}`→`%7D`); `@`, `T`, `:`, `Z` stay literal.

**Why** — A bare repo-root link tracks moving HEAD; by the time a reader clicks,
the skills have changed and the attribution no longer reflects what produced the
message. GitHub resolves `branch@{<timestamp>}` server-side to the commit at or
before that instant and renders the tree as of then, so the pinned link is a
durable point-in-time view. Verified: raw braces 404; URL-encoded braces 200;
full timestamp (ISO-with-`Z`, `date space time`, and Unix epoch) all resolve; a
bogus ref 404s (proves the timestamp is genuinely resolved, not ignored).

**Where** — `wk-gh` Step 4 (outbound footer block + pre-emit gate). The
`wk-commit` `Generated with [wk-skills](…)` trailer is harness-injected, not
skill-defined, so it is out of scope for a skill edit.
