---
class: principle
---

# Runtime evidence resolves shell hypotheses

**Rule** — For a shell or wrapper finding, inspect the job log's exact rendered
command and a downstream behavioral sentinel before accepting a patch.

**Why** — Static analysis can assume quoting layers absent from the executed
command. A passing aggregate build proves less than a sentinel tied to that
exact command.
