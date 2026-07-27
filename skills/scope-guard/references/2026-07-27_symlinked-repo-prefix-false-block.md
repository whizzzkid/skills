---
skill: wk-scope-guard
class: principle
---

**Rule** — Compare a path operand against the repo root **after resolving symlinks on both
sides**. `git rev-parse --show-toplevel` always reports the PHYSICAL root, while an operand
keeps whatever logical prefix the caller typed. A lexical compare therefore judges an
entirely in-repo search "outside" whenever the repo is reached through a symlinked prefix.

**Why** — On macOS `/tmp`, `/var` and `/etc` are symlinks, so a repo at `/tmp/r` has root
`/private/tmp/r`. `os.path.normpath` collapses `..` but does not resolve links, so
`/tmp/r` failed the prefix test against `/private/tmp/r` and blocked. The failure is silent
in the worst way: it emits a correct-looking BLOCKED banner naming a path that *is* in the
repo, which reads as the guard working rather than misfiring.

**Not a relaxation** — `realpath` only ever tightens the comparison. An in-repo symlink
pointing outside now resolves outside and blocks, where the old lexical compare let it
through; the header comment claiming those "slip through by design" was corrected.

**Disproved root cause** — The field report attributed the block to the hook resolving
"repo root" from the *session's original* working directory rather than the Bash call's
actual `cwd`. Reading the source disproves this: the hook already reads `cwd` from the
PreToolUse payload and derives the root with `git -C "$CWD" rev-parse`. Driven directly with
a payload whose `cwd` is a second, non-symlinked repo and a search rooted in that same repo,
the hook exits 0 — it honors the call's cwd. The reporter's repo was reached through a
symlinked prefix, which is the actual mechanism; "cross-repo" was a coincident property, not
the cause.

**Rejected suggestion** — The report proposed making the hook treat the Bash call's cwd as
the scope boundary "when the cwd is itself a valid, distinct git worktree". Rejected on two
counts: the hook already does exactly that, and the only way to extend it further would be
to honor a `cd` inside the command — which the hook deliberately charges as the *effective
root* precisely so an agent cannot `cd` out of scope and search freely. That is
caller-supplied scope, weaker than scope derived from the session environment, and it
forfeits the property that makes the guard un-rationalizable.

**Confirmed as reported** — An inline `SCOPE_GUARD_OFF=1 <cmd>` cannot work: PreToolUse runs
as a separate process before the command executes, so the assignment never reaches the hook's
environment. Already documented in `SKILL.md`; the gap was that a blocked subagent reads only
the hook's *stderr banner*, which said "set SCOPE_GUARD_OFF=1 for the session" without
warning against the prefix form. The banner now states it, and names rooting the session in
the target repo as the cross-repo fix.

**Escalation note** — No ladder notch spent. The re-violated rule was installed five days
before the failing run, but the failing agent was a delegated subagent that had the hook
active without `SKILL.md` in context. The defect is the guidance's delivery channel, not its
salience, so raising a label in a document the agent never opened would be a no-op.

**Pinned tests** — Three, each verified to flip: in-repo search through a symlinked prefix
(fails pre-fix, passes post-fix), out-of-repo search through a symlinked prefix (passes both
— proves no relaxation), and the banner's prefix-form caveat.

**Where** — wk-scope-guard `hooks/scope-guard.sh` `is_outside()` and block banner;
`SKILL.md` false-block shapes.
