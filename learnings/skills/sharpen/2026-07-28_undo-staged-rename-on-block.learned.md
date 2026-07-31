---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: low
verified-against-source: yes
---

"Leave the source learning unrenamed" on a blocked commit gate is an **undo** step, not a
wait step — the rename is necessarily already staged by the time the gate can block.

**What happened:** A batch run applied a fold, renamed the processed learning to
`.learned.md`, staged the fold plus the rename, and had the commit refused by the signer.
The distilled-not-landed rule says to leave the item unrenamed, but the run was already
past the rename, so honoring the rule meant reversing it: unstage that one path and `mv`
the file back to its plain `.md` name, leaving the fold itself staged. Nothing in the
skill or its commit-gate reference names that reversal, so the ordering reads as "rename
later" — which the filename hook makes impossible.

**Root cause:** The filename hook inspects only *staged* learning paths and accepts nothing
but `<YYYY-MM-DD>_<kebab>.learned.md` (read the hook: it globs the staged diff, so an
unrenamed file staged in the fold's commit blocks it). The rename therefore has to be
staged **inside** the same commit as the fold — it cannot be deferred until after a
successful commit. So every rule of the form "rename only after the fold lands" is really
"rename as part of landing, and undo the rename if landing fails".

**Suggested fix:** State the reversal mechanically where distilled-not-landed is defined —
on a gate refusal after staging, `git reset` the `.learned.md` path and `mv` it back to the
plain `.md` name, keeping the fold's own paths staged so an inheriting run extends that
fold instead of opening a competing one. Note why the rename cannot simply be postponed
(the filename hook only accepts the distilled suffix on a staged learning path).
