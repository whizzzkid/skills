---
class: principle
---

# Workflow skill reference

| Skill | When | Phase |
|---|---|---|
| [`wk-plan`](../../plan/README.md) | Every non-trivial task before implementation | 1 |
| [`wk-commit`](../../commit/README.md) | After each implementation step; CI fix commits | 2, 6 |
| [`wk-workstyle`](../../workstyle/README.md) | Code-quality gate before every commit | 2 |
| [`wk-docs`](../../docs/README.md) | With each commit and final audit | 2, 7 |
| [`wk-pr`](../../pr/README.md) | Creating or updating a pull request | 5 |
| [`wk-self-review`](../../self-review/README.md) | Invoked before the PR skill's CI poll | 5 |
| [`wk-buildkite`](../../buildkite/README.md) | Diagnosing Buildkite CI failures | 6 |
| [`wk-adversarial-review`](../../adversarial-review/README.md) | Single post-publish, pre-merge review gate | 5.5 |
| [`wk-pr-update`](../../pr-update/README.md) | Syncing a PR branch with its base | 5, 6 |
| [`wk-learn`](../../learn/README.md) | Post-completion learning capture | any |
| [`wk-retro`](../../retro/README.md) | End of every session | 8 |
| [`wk-docker`](../../docker/README.md) | Docker and containers | any |
| [`wk-datadog`](../../datadog/README.md) | Observability resources | any |
| [`wk-worktree-cleanup`](../../worktree-cleanup/README.md) | Cleaning merged worktrees | any |
