---
class: principle
---

# `printf '%s'` protects any captured payload, not just JSON

**Rule** — Use `printf '%s'` or a direct pipe for any captured structured payload.
`echo` interprets `\r`/`\n`/`\t` and corrupts the text regardless of its format.

**Why** — The installed rule stated the same mechanism but scoped its subject to
"JSON passed to `jq`". The corruption is `echo`'s escape handling, which is
indifferent to format, so the narrow subject invited the reading that a TSV row,
a base64 blob, or a signature was outside the rule. Widening the subject costs
almost nothing and closes the exemption.

**Where** — `skills/workstyle-shell/SKILL.md` → the string-handling bullet list,
rewritten in place.

## Classification

- `already-covered (unshipped)` for escalation purposes: the JSON-scoped rule
  landed after the reporting session, so it never steered the failing run and
  earns no ladder notch.
- `partial` for content: the mechanism was right, the subject too narrow. Widened
  rather than re-stated, so the rule count is unchanged.
