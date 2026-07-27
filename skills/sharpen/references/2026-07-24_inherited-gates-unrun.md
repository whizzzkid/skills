---
class: principle
---

# Anti-thrash is not gate discharge

**Rule** — on a resumed, signer-blocked fold, distinguish *retry thrash* from *unrun
gates*. Do not loop on the commit, re-stage, or re-distill. Do discharge any gate whose
result the tree does not record: run the shipped-code suite when the fold touched a
shipped executable, and run the owning hooks against the staged diff. Treat an inherited
fold's gates as **unrun** rather than assuming the drafting run completed them. Leave the
index partitioned as the prior run left it.

**Why** — Step 8 carries two rules that read as contradictory on a resumed fold. The
signing rule ("stop; don't re-run install/scan or re-stage") is sound anti-thrash advice
*within* a blocked session, but read as "discharge nothing" it lets verification fall
through a gap in both directions: the drafting run defers to whichever run commits, and
the committing run reads "don't re-run" as covering it. Nothing in the tree records
whether the suite ever ran, so the carry ships unverified executable code.

Running the gates costs little and shrinks the eventual retry to a bare `git commit`.
Staging a second fold merely to hook-check it, by contrast, destroys the path-scoped
commit separation the prior run set up — a real cost for no verification gain.

**Where** — `SKILL.md` → Step 8 → item 3, folded into the existing signing-failure bullet
so the anti-thrash rule and its scope limit cannot be read apart.
