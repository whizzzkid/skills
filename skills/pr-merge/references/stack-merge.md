# Stack merge

Applies when `gh stack view --json` (run before Step 2) shows the PR is a stack member.

1. `gh stack checkout {url}`.
2. Reconcile membership parity per
   [`2026-07-30_remote-stack-membership-parity.md`](2026-07-30_remote-stack-membership-parity.md).
3. Apply Steps 2–5.5 to all members.
4. Merge atomically:

```bash
gh stack merge {stack-or-pr-number} --yes --merge-method {allowed-method}
```

Extension lacks `merge` → stop, request upgrade approval.
