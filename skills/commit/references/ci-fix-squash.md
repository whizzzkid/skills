# Post-CI-Fix Squash Offer

## Single Trivial Follow-Up → Offer `--amend`

When a CI fix produces one trivial follow-up that is clearly a correction to the
*immediately prior* commit, surface an explicit `--amend` suggestion for the user
to approve in the same response — do not silently create a separate commit and
defer cleanup to retro.

- Auto mode blocks `git commit --amend` as history-rewriting → it needs explicit
  user confirmation. Ask once, at the fix site, rather than accumulating commits
  the user must later squash by hand (`git rebase -i HEAD~N`).
- **The amend prohibition holds regardless of push state.** An unpushed commit is
  not a license to self-initiate `--amend` — unpushed status changes the blast
  radius, not the rule. Fold a follow-up by creating a NEW commit; surface the
  amend/squash as an explicit suggestion for the user to approve.
- Prior commit already pushed → the amend forces a force-push; flag that in the
  same ask (force-push rules below apply).

## Batch Squash After CI Fix Loop

After the CI fix loop (`wk-workflow` Phase 6) exits green, before marking the PR
ready, offer to squash a long tail of small `fix(ci):` commits into one.

- Threshold: ≥3 commits matching `^fix(\(ci\))?:` ahead of base **and** their net
  diff <50 lines (single config file or a handful of related ones). Detection
  commands and ask template:
  [`ci-fix-squash-detection.md`](ci-fix-squash-detection.md).
- **Do not auto-squash** — destructive; the user must approve.
- **Never squash across user-authored commits.** A user commit mid-chain → leave
  the chain intact.
- **Confirm the force-push** a squash forces on an already-pushed branch.
- **Name the actual fix in the new subject, not the journey** —
  `fix(ci): ⬇️ downgrade and pin {dep} {version}` beats "squashed CI fix attempts".
- Thresholds unmet or user declines → leave history alone.
