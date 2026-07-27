---
skill: wk-workstyle-shell
class: principle
---

**Rule** — Keep every shell command the agent runs portable across bash *and* zsh. Two
verified traps: `for x in $LIST` (unquoted parameter expansion) and `${!var}` (indirect
expansion).

**Scope widened (superseding this file's original wording)** — first stated as "any
snippet a skill documents", which a later run read past: the failing command was one the
agent composed ad-hoc, not a documented snippet. The mechanism is a property of the
shell, not of the authoring context, so the rule now covers documented and ad-hoc
commands alike.

**Why** — The agent's shell is not guaranteed to be bash. Verified by reproduction
under zsh 5.9:

- Unquoted *parameter* expansion does not word-split, so `for x in $LIST` runs the body
  once over the whole newline-joined blob; every element-wise command fails, and any
  no-match sentinel survives untouched — the failure presents as a plausible *domain*
  result ("nothing matched", "detection failed") rather than a syntax error, so it gets
  diagnosed as real. Unquoted *command substitution* `$(cmd)` does split under both
  shells, but still breaks on whitespace inside an element.
- `${!var}` aborts the entire snippet with `bad substitution`.

Portable forms: `while IFS= read -r x; do …; done <<< "$LIST"`; and
`if val=$(printenv "$var"); then …` (rc 1 = unset, rc 0 + empty output = set-but-empty).

**Note on the reported cause** — the field report attributed the loop failure to branch
names containing whitespace or glob characters. Reproduction disproved that as the
operative mechanism for the observed run: plain names fail too, because the split never
happens at all under zsh. The rule is written against the verified mechanism.

**Where** — wk-workstyle-shell Rules; consuming instances corrected in the same pass
were a candidate-iteration loop in the PR base-detection snippet and an unset/empty
discriminator in an env-diagnostic snippet.
