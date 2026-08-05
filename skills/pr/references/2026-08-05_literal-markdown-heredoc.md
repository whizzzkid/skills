---
class: principle
---

# Compose Markdown PR bodies with quoted heredocs

**Rule** — Use a single-quoted heredoc delimiter for every Markdown PR body. Before and after each write, verify
expected literal markers and reject an empty, implausibly short, or shorter-than-submitted server body.

**Why** — An unquoted heredoc evaluates Markdown backticks as command substitutions before posting.

**Where** — Hard Rule 0 body composition and verification.
