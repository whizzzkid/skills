---
skill: wk-pr-resolve
date: 2026-06-22
type: gap
severity: high
---

Conflict resolution must happen at Step 2 sync, not as a deferred "before you start" reminder from the user.

**What happened:** The user invoked the skill with an explicit note "don't forget to resolve conflicts before" — indicating the skill had previously attempted to triage or apply fixes on a conflicted tree, or had silently skipped conflict resolution and the user had to redirect.

**Root cause:** Step 2 sync instructions mention rebasing and base integration but do not make an explicit "abort if conflict markers present" gate the first action. When the tree is already dirty with conflict markers, the skill proceeds to fetch comments and generate suggestions before the tree is clean.

**Suggested fix:** Add an explicit pre-flight at the top of Step 2: `git diff --check` to detect conflict markers; if any exist, resolve them (or run `wk-pr-update`) before fetching any comments. Never triage on a conflicted tree — it leads to commits that embed conflict markers or suggestions that apply to a stale diff.
