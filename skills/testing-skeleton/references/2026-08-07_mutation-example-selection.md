---
class: principle
---

# Mutation evidence needs the intended example

**Rule** — Target a mutation check by exact behavioral example description and
confirm that name in runner output.

**Why** — Location filters drift as tests move. A passing adjacent example does
not demonstrate the mutation exercised the intended behavior.
