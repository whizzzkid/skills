---
skill: wk-workflow
date: 2026-10-29
type: correction
severity: high
verified-against-source: n/a
---

Agent posted outbound GitHub comments without first invoking the skills that govern them (wk-gh, wk-tone).

**What happened:** Mid-takeover, the agent ran `gh pr comment` and reply/reaction `gh api` writes directly. The
skills that own those surfaces were never loaded, so their HARD RULES (canonical footer, terse body, voice) were
silently skipped. The user had to point it out.

**Root cause:** The agent treated "post a comment" as a trivial step inside a larger skill and relied on a generic
attribution reminder instead of the owning skill. Calling skills say "post a comment" without naming the skill that
must run first, so nothing forces the load.

**Suggested fix:** Add a pre-write gate to wk-workflow: before ANY outbound write (gh, Jira, Slack, docs), invoke the
owning skill (wk-gh, wk-tone, wk-jira, wk-slack) in that turn, even when a parent skill is already active. Each calling
skill's "post comment" step should name the skill to invoke. A system-provided PR-description attribution line is not
the comment footer.
