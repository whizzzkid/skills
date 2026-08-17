---
class: principle
---

# A shared symbol's verification scope is its callers' suites

**Rule** — Refactoring a guard, helper, mixin, or base class many callers depend on
→ run the full suite for every directory exercising those callers, at each refactor
commit boundary. Enumerate callers first by grepping the symbol, then map them to
suite directories. Never infer scope from the diff's file list.

**Why** — The skill's first hard rule already says a green suite is not
preservation, but it argues about *what* green proves, never about *which* tests
ran. A shared-guard refactor whose semantics inverted passed the targeted specs for
the edited paths — those specs exercise the guard through one caller — while
sibling callers broke and the regression reached CI. The diff's file list is
precisely the wrong scope signal for this class: the whole point of a shared symbol
is that its callers are elsewhere.

**Where** — `skills/refactor/SKILL.md` → Hard Rules, as rule 5 beside the
"tests passing is not preservation" rule it completes.

## The other lesson from this source was already covered

The merge-path lesson (`gh pr merge` failing when GitHub flags a PR as a stack
member server-side, independent of local stack view; needing a fallback and a
resume-from-already-MERGED path) is fully installed in the merge skill: the
async-merge fallback chain ending in a user-run REST command with a Step 1 re-run,
plus the mutation-boundary rule that skips to the post-merge step when the PR is
already `MERGED`, plus the local/remote stack-membership parity reference.

**No escalation notch.** That fallback landed 2026-08-14 at 08:04Z against a
retrospect written 07:37Z the same day — 27 minutes *after*, so it never steered
the failing run. `already-covered (unshipped)`.

## Drift check performed

Recounted the numbered hard rules from source after inserting rule 5 (five) and
grepped for any prose asserting a count ("four hard rules") — none exists, so no
stale enumeration to update. The counting probe was proven to fire by printing
every member it matched.
