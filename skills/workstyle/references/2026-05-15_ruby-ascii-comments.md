---
class: principle
---

- **Rule:** Ruby source comments use ASCII only — `-`, `->`, `--`, `...`. No em dash (`—`), en dash (`–`), smart quotes, or Unicode ellipsis. Applies to `.rb` files and bin scripts loaded as Ruby.
- **Why:** RuboCop's `Style/AsciiComments` cop is on by default in many Ruby shops; non-ASCII characters trigger lint failures that require follow-up fix commits. Project config wins — if `.rubocop.yml` disables the cop, this rule is suppressed automatically.
- **Where:** Step 2 → Ruby section, new bullet after `No rescue Exception`.
