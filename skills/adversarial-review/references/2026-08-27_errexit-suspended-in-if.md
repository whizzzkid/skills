---
class: principle
---

- **Rule:** When a finding identifies a language/runtime gotcha at one call site, sweep every function/block in the touched library invoked from the same call shape — one instance structurally implies siblings.
- **Why:** A review caught errexit suspension (`if ! fn; then` suspends `set -e` for the function's whole body) in one helper but missed an identical sibling in the same library; the sibling sweep was treated as file-local instead of library-wide.
- **Where:** Sweep 2.92 in extended catalog; general sibling-sweep principle in 2.88.
