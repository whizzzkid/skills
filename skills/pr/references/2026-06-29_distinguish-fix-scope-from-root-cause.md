---
class: principle
skill: wk-pr
date: 2026-06-29
---

**Rule** — When an observable symptom (failing health check, error, outage)
triggered the work but the code change only addresses a related gap — not the
symptom's root cause — the PR Summary must carry a prominent first-lines
one-liner stating what the PR does NOT fix and what the real fix requires
(tracked elsewhere).

**Why** — A security-fix PR was opened for a symptom whose root cause was an
out-of-code infrastructure gap. The body described what changed but buried the
"does not fix the health check" distinction; the user had to ask mid-session
whether the change resolved the trigger. The body template prompted "what
changed" with no prompt for "what this does NOT fix."

**Where** — Step "Resolve PR Body Template", as a body-composition rule applying
to both repo-template and fallback bodies.
