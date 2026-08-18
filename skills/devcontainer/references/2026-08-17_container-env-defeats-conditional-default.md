---
class: principle
source: learnings/skills/workflow/2026-08-17_devcontainer-rails-env-leak.md
date: 2026-08-17
severity: medium
---

## Unconditional container env defeats the app's conditional default

The compose service set the app's mode env var unconditionally. The test harness
bootstrap assigned the same name conditionally, so it deferred to the value already
present and the whole suite ran in the container's mode instead of test mode, erroring
on infrastructure that mode does not provide.

**Failure mode:** the two halves are individually correct — compose declares an
explicit mode, the harness declares a safe default. The collision is only visible at
run time, and it presents as a broken test suite rather than a misconfigured
container, so every caller diagnoses it as a code defect.

**Guard:** before adding any name to a compose `environment:` block, grep the app's
bootstrap and test-harness files for that name. A conditional assignment
(`||=`, `:-`, `setdefault`) there means the name must be omitted from compose — the
app already owns its default.

**Rejected suggestion:** the report proposed briefing agents with a per-invocation
override, and alternatively rewriting the harness's conditional assignment to an
unconditional one. The override leaves the trap armed for the next caller, and
hardening the harness removes a legitimate default so the app can no longer be run in
another mode deliberately. Both treat the symptom; the compose entry is the defect.

**Landed in:** `SKILL.md` Step 3 → "HARD RULE — never set an env var the app's own
bootstrap conditionally defaults".
