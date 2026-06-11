---
class: principle
---

- **Rule** — Guard the draft file with `[[ -s "$DRAFT" ]]` before the
  validation grep / append; fail loudly when it is empty.
- **Why** — An empty/unset `$DRAFT` appends nothing and passes every grep
  validation silently, writing a blank retro entry with no error.
- **Where** — Step 3 validation gate, immediately after the `DRAFT=` line.
