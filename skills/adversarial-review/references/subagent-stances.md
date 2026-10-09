# Adversarial Subagent Stances

Loaded from SKILL.md Step 3. Brief the subagent with every stance below, in addition to adversarial, objective,
naming-aware, and diff-sensitive.

- **Coverage-aware:** test-only commits → enumerate paths, flag unexercised ones. But a private helper exercised
  transitively through its public caller *is* covered — don't flag a coverage gap on it, nor on a sibling branch already
  exercised by an equivalent case (coupling tests to private helpers couples them to implementation detail).
- **Narrate the "why" on a narrow merge-resolution/bugfix diff:** name the kept conflict side and the bugfix's exact
  defect mechanism, and tell the subagent to verify those claims against the diff, not assert them. A large/organic diff
  still needs the generic sweep.
- **Refactor-aware:** demand removed-line audit; every removed line is relocated or intentionally dropped.
- **Relocation-aware:** downgrade inherited pre-existing issues carried unchanged by a pure move — but not when the diff
  *deleted* the alternative that was masking the issue (2.4).
- **Introduction-claim-aware:** before calling a behavior newly introduced, grep the `-` lines of the same hunk.
- **Runtime-behavior-cautious:** never `blocker` a tool-behavior-under-failure claim (exit codes, signals, buffering,
  pipe semantics) from first principles — at most `question` pending the Step 5 repro (Contract 7).
- **Absence-claim-cautious:** a finding that a "safe no-op" or missing error-path write is a defect must cite a concrete
  failure scenario. Absence of defensive code is not itself a defect — writing a default (e.g. `{}`) on read failure can
  clobber legitimate local-only state. Cap at `question` without a repro.
- **Intent-aware:** weigh the PR title/body purpose (piped in above). A change the PR explicitly documents as
  intentional, test-only, or throwaway (e.g. a CI gate removed to force a step to run) is stated context — do not flag
  documented-intentional design as a `blocker`. The guard still holds on production branches, where the pattern is
  unflagged.
- **Design-invariant-aware:** when a diff adds a helper/function beside existing code carrying a design-rationale
  comment (e.g. a global cleaned by an EXIT trap on signal), verify the new code honors that stated invariant; a
  divergence is a structural bug.
- **Artifact-provenance-aware:** state derived from a produced artifact (summary, report, comment, log) must be gated on
  the artifact's production fidelity — a degraded, partial, or fallback production path voids any state inference drawn
  from the artifact's content or existence. "Artifact exists" ≠ "artifact is complete."
