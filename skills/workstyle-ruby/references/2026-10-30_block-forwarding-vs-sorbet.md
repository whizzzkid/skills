---
class: principle
skill: wk-workstyle-ruby
date: 2026-10-30
severity: medium
---

**Rule** — In a method carrying a Sorbet `sig`, never forward a named block bare (`def m(&blk); run(&blk); end`).
Reference the block as a value (`return x unless blk`, `run { blk.call }`) so `Naming/BlockForwarding` has nothing to
rewrite and no disable directive is needed.

**Why** — With a Ruby target that supports anonymous block forwarding, the cop autocorrects `&blk` to `&`. Sorbet sigs
cannot name an anonymous block, so sorbet-runtime raises at sig build:
`The declaration for 'handle' is missing parameter(s): & (RuntimeError)` — every call fails. Reproduced locally with
rubocop 1.92 + sorbet-runtime 0.6: the bare-forward form gets two correctable offenses and raises after `-a`; the
value-reference form is offense-free and runs. A `rubocop:disable Naming/BlockForwarding` directive is not a fix when
two configs lint the same code (a generator repo and its generated app): one reports the directive as redundant, the
other autocorrects once it is gone.

**Where** — `SKILL.md` → "Sorbet strict-mode friction (typed Rails apps)".
