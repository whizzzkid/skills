---
skill: wk-sharpen
date: 2026-06-26
type: gap
severity: medium
---

When a learning is skipped because its subject is a prohibited term, the commit message that records the skip must not name the term either — a separate commit-msg hook scans the message.

**What happened:** A high-severity learning about a prohibited-subject tool was correctly skipped from the public fold (gate working as designed). The commit message explained the skip and named the tool. The first commit passed every pre-commit file hook but was rejected by the `commit-msg` stage prohibited-term scan; a second commit with the term replaced by a category description ("a prohibited-subject tool") succeeded.

**Root cause:** wk-sharpen's prohibited-subject gate and overfit scan target staged files (`grep -iEnf .skillprohibit $(git diff --cached --name-only)`) but say nothing about the commit message body. The natural way to document "why this fold was skipped" reintroduces the exact token the gate just removed.

**Suggested fix:** In the prohibited-subject gate (and Step 8 commit step), add: when a fold is skipped or routed-private due to a prohibited subject, describe it in the commit message by category only — never name the token. The message is scanned by the same term list as files; a name there costs a failed-commit + re-author cycle.
