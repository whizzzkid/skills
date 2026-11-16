---
class: principle
---

**Rule** — Wait on a background task through its completion notification. When a process-match probe is
unavoidable, bracket one character of the pattern (`[t]ask` for `task`) so the regex cannot match any waiter's own
command line.

**Why** — `pgrep -f` / `ps | grep` match every live argument list carrying the pattern text, and the waiters are such
processes:

- macOS/BSD `pgrep` excludes itself and its ancestors (`-a` re-includes them), so a single waiter exits correctly —
  but two concurrent waiters on the same pattern each match the other's shell and stay armed until timeout.
  Reproduced: two sibling `until ! pgrep -f <pat>` loops both timed out after the target exited; the bracketed form
  exited on time in both.
- procps `pgrep` (Linux) excludes only itself, so the waiter's own wrapper shell matches even with one waiter (per the
  man page; not reproduced in this pass).
- The bracketed regex `[t]ask` matches the text `task` but not the literal text `[t]ask` in the waiter's argv.
- A prefix-overlapping pattern also matches unrelated long-lived processes (a short `sleep N` pattern matched an
  unrelated `sleep <N...>`), so a probe pattern needs a unique token, not a bare command name.

**Where** — `SKILL.md` → Phase 6 → CI watch / long-watch bullets.
