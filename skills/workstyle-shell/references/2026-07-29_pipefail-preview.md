---
class: principle
---

# Non-assertive previews can abort pipefail gates

**Rule** — keep previews out of `pipefail` validation gates unless their consumers drain the full stream. Make each
gate command assert one property.

**Why** — an early-closing consumer can give its producer SIGPIPE (often rc 141). Under `pipefail`, an irrelevant
preview then aborts the gate before its assertions run.

**Where** — `SKILL.md` → Rules, adjacent to the verdict-pipeline rule. That existing rule protects a verdict from
the last pipeline command; this addition covers a preview whose status is irrelevant but still fatal.

**Budget** — body `23989 + 246 = 24235` bytes, leaving 341 bytes. Full-skill audit found no cleanup, so measured audit
allowance was 0 bytes.
