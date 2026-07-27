---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: low
verified-against-source: yes
---

An inherited signer-blocked fold can have unrun Step 8 gates; Step 8's anti-thrash "don't re-run install/scan" is being read as "discharge nothing", leaving the retry to carry unverified shipped code.

**What happened:** A batch run opened with all four sources drained and a prior session's
prepared work in the tree — one staged fold that edited a shipped hook script plus a new
test suite, and one unstaged docs-only fold. Signing was still down, so no commit was
possible. Step 8 gate 2 requires a fold touching a shipped executable to run that skill's
suite before committing, but nothing in the tree records whether the prior session ran it.
Running it (14 cases, all green) and the repo hooks against the staged index (all clean)
cost little and reduced the eventual retry to a bare `git commit`.

**Root cause:** Step 8 carries two rules that read as contradictory on a *resumed* fold.
The signing rule says "stop — don't re-run install/scan or re-stage", which is sound
anti-thrash advice *within* the blocked session. Gate 2 (run the suite for shipped-code
edits) is owed by whichever run commits. Neither rule says who discharges gate 2 when the
run that drafted the fold could not reach the commit, so the verification can fall through
the gap in both directions — the drafting run defers it to the committing run, and the
committing run reads "don't re-run" as covering it.

**Suggested fix:** Distinguish *retry thrash* from *unrun gates* in Step 8. On a
signer-blocked or inherited fold: do not loop on the commit and do not re-stage or
re-distill, but do discharge any gate whose result is not recorded in the tree — run the
shipped-code suite for gate 2 and the owning hooks against the staged index — exactly once,
then stop at the commit. Verification state is not inferable from a staged diff, so treat an
inherited fold's gates as unrun rather than assuming the drafting run completed them. Leave
the index partitioned as the prior run left it; staging a second fold to hook-check it
destroys the path-scoped commit separation the prior run set up.
