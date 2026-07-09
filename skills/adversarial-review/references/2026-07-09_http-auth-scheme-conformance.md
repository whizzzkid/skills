---
skill: wk-adversarial-review
class: principle
---

**Rule** — Add a mechanical sweep (catalog row 2.66) triggered by any regex/parse
of an `Authorization` or `WWW-Authenticate` header: flag a case-sensitive scheme
match (RFC 7235 `auth-scheme` is case-insensitive → needs `/i`) and a single
literal-space separator (RFC 7235 separator is `1*SP` → one-or-more spaces).

**Why** — A `Bearer <token>` parser matching a fixed-case literal and one space
is plausible-but-wrong; it passes mechanical review and manual reasoning is the
only thing that catches it. A conformant server must accept lowercase schemes and
multiple spaces even though canonical clients send neither. Suggestion severity:
real clients rarely trigger it, but the conformance gap is real.

**Where** — wk-adversarial-review Step 2 extended sweep catalog (row 2.66).
