---
class: principle
skill: wk-workstyle-shell
date: 2026-07-25
severity: high
---

**Rule** — Prefix `command` on any tool invocation whose clean/zero result is load-bearing.
A bare name resolves to a shell function or alias *before* the binary; an agent shell may
wrap a standard tool so it re-execs a different engine with implicit options the caller
never passed. Identical flags then diverge in semantics, and the divergence surfaces as a
**missing match, not an error** — empty output, empty stderr, status indistinguishable from
a genuine clean. Prove a positive control in the **same invocation form** as the real scan.

**Why** — The reported failure mode is a false *clean*: the one direction no exit status or
stderr signals. `type <name>` is not a clearance — it can report only an alias while a
function sits behind it, and a non-interactive shell skips alias expansion yet still honors
the function, so the layer that actually runs is the one `type` did not show.

**Verified against source** — Driving both forms in the live agent shell:

- `declare -f` revealed a function wrapping the tool, re-execing the agent CLI under a
  different engine name with implicit file-filtering and dialect flags prepended.
- Banner divergence, reproduced: the bare name printed one engine and vendor version, the
  `command`-prefixed name a different engine entirely. Two implementations, one spelling.
- The alias is a red herring, confirmed: `type` reported an alias, yet the bare call ran
  the **function** — non-interactive shells do not expand aliases.

**Reported mechanism NOT reproduced (do not re-document it)** — The field report attributed
the false-clean to the wrapper's implicit ignore-file option changing `-f <pattern-file>`
match semantics. Driven directly, that did not reproduce: an explicitly-named ignored file
matched under **both** forms, and a recursive scan surfaced ignored files under both. The
durable, demonstrable mechanism is engine substitution itself — pattern-dependent dialect
divergence between two implementations — not any one option. Per the Step 1 rule, the fold
states the formulation the source can be driven to demonstrate.

**Escalation** — None. The sibling zsh-portability rule's ad-hoc-command strengthening was
present in the working tree but **absent from the installed skill**, so the re-violation
cited as evidence of a failed fold occurred under text that never shipped. An unshipped
rule cannot have failed; escalating it would harden a rule that has not yet been in force.

**Where** — Rules list, adjacent to the positive-control / silent-zero trap family.
