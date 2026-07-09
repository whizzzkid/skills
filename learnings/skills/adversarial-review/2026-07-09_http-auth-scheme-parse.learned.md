---
skill: wk-adversarial-review
date: 2026-07-09
type: gap
severity: medium
---

HTTP auth-header parse regexes are silently non-RFC-7235-conformant when scheme is case-sensitive or the separator is a single space.

**What happened:** A `Bearer <token>` Authorization-header parser matched a fixed-case scheme literal (`Bearer`) and a single literal space before the token. Both are non-conformant: RFC 7235 defines `auth-scheme` as a case-insensitive token and the scheme/credentials separator as `1*SP` (one or more spaces). The gap was caught in adversarial review but only by manual reasoning, not a catalogued sweep.

**Root cause:** No sweep covers HTTP authentication-header parsing conformance, so a plausible-but-wrong scheme regex passes mechanical review.

**Suggested fix:** Add a sweep triggered by any regex/parse of an `Authorization` (or `WWW-Authenticate`) header: flag a case-sensitive scheme match (needs case-insensitivity, e.g. `/i`) and a single-space separator (RFC 7235 `1*SP` → one-or-more). Severity suggestion since real clients typically send canonical casing and a single space, but a conformant server must accept both variants.
