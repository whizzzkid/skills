---
skill: wk-adversarial-review
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

A raising lookup inside verifier code silently converts a real finding into a passed commit when the wrapper treats that exit status as non-blocking.

**What happened:** A branch added a contract-drift gate: a service returning one string per disagreement, a rake task exiting **2** on drift and **1** on boot failure, and a pre-commit hook wrapper that blocks only on exit 2 and downgrades every other non-zero status to a warning (so a developer on a checkout with no running stack is not taught `--no-verify`). Two `fetch` calls sat inside drift checks. A renamed column or a serializer that drops a nested object — precisely the drift the gate exists to catch — raised instead of reporting, exiting 1, which the wrapper downgraded to a warning and let the commit through. The mechanical sweeps read the service in isolation and cleared it; an automated reviewer caught both as Majors. Worse, the first one had already been fixed earlier in the same branch and no sibling sweep was run, so the second shipped.

**Root cause:** The catalog has no sweep that models the **exit-status contract** a diff participates in. Every sweep asks "is this code correct?"; none asks "what status does this failure produce, and how does the caller read that status?". In a gate, hook, linter, verifier, or CI wrapper the caller's status-to-severity mapping is part of the contract, and an exception routes to the *wrong branch* of it — fail-open in artifact-producing code.

**Suggested fix:** Add a sweep, triggered when a diff adds or edits code whose caller distinguishes exit statuses (rake verifier, linter, hook wrapper, CI gate, `--check`/`--verify` mode):

1. Read the wrapper and record its status→severity mapping (which codes block, which warn, which are ignored).
2. Enumerate every raising lookup inside the checked code — `\.fetch\(|T\.must\(|T\.let\(|unwrap\(|panic|\[\]!|!\.` — plus anything that can throw on absent/renamed input.
3. Each must either report a finding through the normal return path or be provably unreachable. **Blocker** when a raise routes to a status the wrapper treats as non-blocking.
4. After any raise→report conversion, sweep siblings for the same shape before clearing — one instance of this class implies others.

Two companion requirements when a raise→report conversion lands:

- **Cover the new branch.** Converting a raising lookup to a nil-tolerant one adds a branch no existing control drives; without a control on it, a regression to the raising form still passes. Require mutation verification: restore the raising form, confirm exactly the new control fails, restore.
- **Check for over-firing, not just under-firing.** A separate finding in the same diff: a check read a field from only one level of a spec format that documents inheritance from an enclosing level, so an idiomatic edit (lifting a shared declaration up) reported *false* drift and would block a valid commit. When a check reads a field from a spec/config format with documented inheritance, merging, defaulting, or reference-resolution semantics, verify it honours them, and add a **positive** control asserting the idiomatic-but-unusual form reports nothing. In a blocking gate a false positive is as costly as a false negative — it is what teaches `--no-verify`.

Meta: the catalog is rich in "does this check fire?" and thin on "does this check fire *wrongly*?" and "who reads the status this failure produces?". Both belong as explicit triggers.
