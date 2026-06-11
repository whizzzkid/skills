---
class: one-off
---

- **Scenario** — A file edit must insert a literal null byte (`\x00`) or other
  non-UTF-8 byte (e.g. a duplicate-detection key using `\x00` as separator).
- **Symptom** — The Edit tool silently drops the null byte from `new_string`
  (UTF-8 encodes the replacement), producing a wrong result with no error.
- **Fix** — Use Python for a binary-exact replacement:
  `data = open(path,'rb').read().replace(b'old', b'new'); open(path,'wb').write(data)`.
  Never pass `\x00` through Edit's `new_string`.
- **Why not promoted** — Narrow: fires only when inserting non-UTF-8 bytes, a
  configuration the agent rarely encounters; a verbatim recipe, not a general rule.
