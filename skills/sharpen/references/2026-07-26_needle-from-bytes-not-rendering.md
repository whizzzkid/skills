---
class: principle
skill: wk-sharpen
date: 2026-07-26
severity: high
---

# A landing-check needle comes from the file's bytes, never a tool's rendering

**Rule** — the literal a landing check greps for must be extracted from the target
file's bytes (`command grep -o`, or a byte read) and, wherever possible, compared
in-shell so the verdict — not the literal — is what crosses into the transcript.
Never transcribe a needle from what a tool *displayed*. A display layer may
normalize the text it renders without signalling, so a needle copied out of it can
fail to match content that is genuinely present.

**Why** — the transcript's rendering layer was observed to mutate tool results three
distinct ways, all silent:

- **Elision** — whole spans replaced by a compression marker (`…,754B`), so the text
  simply is not there to copy.
- **Function-word dropping** — articles and auxiliaries deleted from otherwise
  intact prose (a source line reading `rule cannot have steered the failing run`
  rendered as `rule cannot steered failing run`).
- **Line joining** — a 78-line file rendered as a near-single blob, so a needle
  spanning a source line break matches nothing on disk.

Any one of these turns a fixed-string grep into a false `MISSING` against text the
file genuinely contains. The failure is silent and inverts the landing verdict in
the dangerous direction: a fold that *did* land reads as missing, which invites a
re-fold and a competing edit into a tree already carrying prepared, path-disjoint
folds. The failed-control rule is what caught it — the same invocation form was
proven able to return a hit.

**Distinct from the already-folded escaping variant** — that case mis-*escaped* a
correctly-sourced literal (a regex `.` where the source has `**`); the bytes were
right and the pattern was wrong. Here the pattern is right and the *source of the
literal* is wrong. Escaping discipline cannot catch it, because a needle taken from
a lossy rendering is already the wrong string before any escaping is applied.

**Verified against source** — not taken from the report. Reproduced first-hand in
the distilling run: a `Read` of `SKILL.md` came back with `…B` elision markers, and
a `sed` of a reference file came back with articles dropped and lines joined —
establishing that this is a property of the **transcript's rendering of any tool
result**, Bash stdout included, not of the `Read` tool as the report framed it. The
fold was re-derived from that broader mechanism rather than patching the reported
wording. Controls: an article-dropped needle and its article-restored form both
returned `MISSING`, while a needle cut from the bytes with `command grep -o`
returned `PRESENT` in the identical invocation form — the restored form still missed
because the true on-disk wording differed again, which is the point: only the bytes
are authoritative.

**Classification** — `principle`. Generalizes to any verification whose literal is
read off a rendered surface — landing checks, coverage greps, canary confirmation.

**Escalation** — None. No existing rule governed where a needle's text comes from;
the adjacent rule (`a landing check reads the worktree`) fired correctly on its own
question, which copy to read. This is a new gap, not a re-violation.

**Where** — `SKILL.md` → `HARD RULE: re-violation escalation`, folded as a
tightening of the existing trailing landing-check clause: `a *landing* check reads
**worktree** bytes, never installed or a tool's rendering.` Placed there because
that clause is the one rule naming which copy a landing check reads; the byte-vs-
rendering question is the same reader's next step, and extending it states both in
one place rather than adding a second, separable rule.

**Byte arithmetic** — body 24530 / 24576 before (46 B headroom). Reclaim pool 0 B:
exhausted, every remaining candidate carrying a recorded stay-inline or
rejected-relocation note, corroborated across six reference records. Audit cleanup
**measured, not reserved**, at 0 B — all twelve `references/` links resolve, README
version already in lockstep, no relocatable duplicate. Reclaim exhausted with net
still positive → tightened the *addition*: rewrote the existing clause in place
(+24 B NET) rather than appending a new bullet (+45 B) or one carrying a parenthetical
rationale (+67 B, which breached the ceiling at 24597). Projected and measured body
**24554 / 24576**, 22 B clear. The 1.2× reclaim ratio is unreachable at reclaim=0;
the binding ceiling still clears, so the arithmetic is reported rather than the hunt
widened into load-bearing content.

**Rejected drafts (do not re-propose)** — the variant carrying the mechanism inline
as a parenthetical (`(display layers elide and reflow silently)`) measures 24597 B
and breaches the ceiling; the mechanism belongs here, in a reference, which is not
ceiling-bound. A separate new bullet at the Source 2 landing site was also rejected:
it costs nearly twice the bytes and splits one rule across two sites.

**Rejected reclaim targets (do not re-propose)** — none newly proposed. The
category-1 pool (an inline rule ending in a `references/…` pointer whose linked
reference states it in full) was re-enumerated this run and remains exhausted.
