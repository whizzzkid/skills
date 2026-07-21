---
class: principle
skill: wk-commit
date: 2026-07-21
severity: high
---

- **Rule:** Never construct a `Co-Authored-By:` email from a GitHub login plus a
  guessed corporate domain (`<login>@<company>`). The current user's co-author
  address is `$WK_SKILLS_EMPLOYEE_EMAIL`; unset/empty → STOP and require the var
  (never guess, never silently omit). Another person's co-author uses their
  `<id>+<login>@users.noreply.github.com` form, or omit the email if unknown.
- **Why:** A fabricated `<login>@<company>` address misattributes every commit to
  a mailbox the person may not own, and it leaks a plausible internal address into
  public history. "Real identities only" is unenforceable without a concrete
  source, so the agent defaulted to a domain guess.
- **Where:** wk-commit → "HARD RULE — never fabricate a `Co-Authored-By:` email";
  cross-referenced by wk-pr-resolve (Rule 9 co-author attribution) and
  wk-pr-takeover (co-author trailer). All three declare `WK_SKILLS_EMPLOYEE_EMAIL`
  in `env-vars` so the pre-skill env check surfaces it; wk-pr declares it too.
