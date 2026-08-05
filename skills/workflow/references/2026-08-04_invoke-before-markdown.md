---
class: principle
---

# Format ownership is an edit pre-flight

**Rule** — Before the first patch, enumerate intended file types and content
constructs, then invoke every applicable format-specific skill. The invocation
must precede its first matching edit; auditing after the write is too late to
shape the artifact.

**Why** — Planning a documentation update establishes scope but does not load
the format owner's constraints. A post-edit invocation can detect drift, yet it
cannot make the original write follow the required process.

**Where** — `SKILL.md` → Phase 2, immediately after the worktree check.
